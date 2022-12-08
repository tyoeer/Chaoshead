local JSON = require("libs.json")
local LHS = require("levelhead.lhs")

local h = string.char
local PREFIX_EXPECTED = h(0xFB)..h(0x08)..string.rep(h(0x00),6)..h(0x12)
local SEPERATOR_A_EXPECTED = h(0x57)
local SEPERATOR_B_EXPECTED = h(0x00)..h(0x00)

local function unpack(to)
	if to:sub(-1,1)~="/" then
		to = to .. "/"
	end
	local info = love.filesystem.getInfo(to)
	if info then
		error("Something already exists at "..to)
	end
	if not love.filesystem.createDirectory(to) then
		error("Failed creating directory at "..to)
	end
	
	local fd, err = love.filesystem.read("data","campaign_hardfile")
	if not fd then
		error("Failed reading campaign_hardfile: "..err)
	end
	local fd = love.data.decompress("data","zlib",fd)
	if not fd then
		error("Failed decompressing")
	end
	
	local pos = 1
	local function get(format,peek)
		if not peek then
			local dat = love.data.unpack(format,fd,pos)
			if type(dat)=="string" then
				pos = pos + #dat
				if format=="z" then
					pos = pos + 1 -- NULL byte
				end
				local n = format:match("s(%d+)")
				if n then
					pos = pos + n
				end
			else
				pos = pos + love.data.getPackedSize(format)
			end
			return dat
		else
			return love.data.unpack(format,fd,pos)
		end
	end
	
	-- PREFIX
	
	local prefix = get("<c9")
	if prefix ~= PREFIX_EXPECTED then
		print("Prefix not as expected!")
	end
	local success, mes = love.filesystem.write(to.."prefix.bin", prefix)
	if not success then
		error("Failed writing "..to.."prefix.bin: "..mes)
	end
	
	-- JSON
	
	if get("B",true)~=string.byte("{") then
		error("No start of JSON found at position "..pos..", instead found: "..string.char(get("B",true)))
	end
	local json = get("z")
	json = JSON.decode(json)
	if not json then
		error("Failed to parse JSON",2)
	end
	if not love.filesystem.createDirectory(to.."data/") then
		error("Failed creating data directory at "..to)
	end
	for key,value in pairs(json) do
		local path = to.."data/"..key..".json"
		local success, mes = love.filesystem.write(path, JSON.encode(value))
		if not success then
			error("Failed writing at"..path..": "..mes)
		end
	end
	
	-- SEPERATOR
	
	local seperatorA = get("<c1")
	if seperatorA ~= SEPERATOR_A_EXPECTED then
		print("Seperator not as expected!")
	end
	local success, mes = love.filesystem.write(to.."seperatorA.bin", seperatorA)
	if not success then
		error("Failed writing "..to.."seperatorA.bin: "..mes)
	end
	
	local expectedLevelCount = get("<I2")
	
	local seperatorB = get("<c2")
	if seperatorB ~= SEPERATOR_B_EXPECTED then
		print("Seperator not as expected!")
	end
	local success, mes = love.filesystem.write(to.."seperatorB.bin", seperatorB)
	if not success then
		error("Failed writing "..to.."seperatorB.bin: "..mes)
	end
	
	-- LEVELS
	
	if not love.filesystem.createDirectory(to.."levels/") then
		error("Failed creating levels directory at "..to)
	end
	local nLevels = 0
	while get("B",true)==0x1C do
		get("B") -- move internal offset
		local marker = get("z")
		local level = get("<s4")
		local path = to.."levels/"..marker..".lhs"
		local success, mes = love.filesystem.write(path, level)
		if not success then
			error("Failed writing at"..path..": "..mes)
		end
		nLevels = nLevels + 1
	end
	
	if nLevels ~= expectedLevelCount then
		print("Expected "..expectedLevelCount.." levels, instead found "..nLevels)
	end
	
	-- CHECK HASH IS COMING
	
	local byte = get("B")
	if byte~=0x0B then
		local hex = love.data.encode("string","hex",string.char(byte)):upper()
		error("Expected hash start at position "..(pos-1)..", instead found: "..hex)
	end
end

local function pack(from, toName, compressionLevel)
	
	-- PREP
	
	if toName==nil then toName="campaign_hardfile" end
	if from:sub(-1,1)~="/" then
		from = from .. "/"
	end
	local info = love.filesystem.getInfo(from)
	if (not info) or info.type~="directory" then
		error("No directory at "..from)
	end
	
	local aggregate = {}
	
	local function putRaw(str)
		table.insert(aggregate, str)
	end
	local function put(format,...)
		putRaw(love.data.pack("string", format, ...))
	end
	
	-- PREFIX
	
	local prefix, err = love.filesystem.read(from.."prefix.bin")
	if not prefix then
		error("Failed reading prefix: "..err)
	end
	if #prefix~=9 then
		print("WARN: prefix is not 9 bytes long")
	end
	putRaw(prefix)
	
	-- JSON
	
	local combined = {}
	local dataFiles = love.filesystem.getDirectoryItems(from.."data/")
	for _,file in ipairs(dataFiles) do
		local key = file:match("(.+)%.json")
		local json, err = love.filesystem.read(from.."data/"..file)
		if not json then
			error("Failed reading data at "..file..": "..err)
		end
		combined[key] = JSON.decode(json)
	end
	put("z", JSON.encode(combined))
	
	-- SEPERATOR
	
	local seperatorA, err = love.filesystem.read(from.."seperatorA.bin")
	if not seperatorA then
		error("Failed reading seperatorA: "..err)
	end
	if #seperatorA~=1 then
		print("WARN: seperatorA is not 1 byte long")
	end
	putRaw(seperatorA)
	
	putRaw("")
	local levelCountPos = #aggregate
	
	local seperatorB, err = love.filesystem.read(from.."seperatorB.bin")
	if not seperatorB then
		error("Failed reading seperatorB: "..err)
	end
	if #seperatorB~=2 then
		print("WARN: seperatorB is not 2 bytes long")
	end
	putRaw(seperatorB)
	
	-- LEVELS
	
	local levels = love.filesystem.getDirectoryItems(from.."levels/")
	local nLevels = 0
	for _,file in ipairs(levels) do
		local marker = file:match("(.+)%.lhs")
		local level, err = love.filesystem.read(from.."levels/"..file)
		if not level then
			error("Failed reading data at "..file..": "..err)
		end
		nLevels = nLevels + 1
		put("B",0x1C)
		put("z",marker)
		put("<s4",level)
	end
	
	aggregate[levelCountPos] = love.data.pack("string","<I2",nLevels)
	
	-- HASH
	
	put("B",0x0B)
	local data = table.concat(aggregate)
	local hash = LHS.hash(data)
	data = data..hash..h(0x00)
	
	-- COMPRESSION & write
	
	local data = love.data.compress("data","zlib",data,compressionLevel)
	local success, mes = love.filesystem.write(toName,data)
	if not success then
		error("Failed writing "..toName..": "..mes)
	end
	
end

return {
	unpack = unpack,
	pack = pack,
}