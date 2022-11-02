local P = require("levelhead.data.properties")
local NFS = require("libs.nativefs")

local LHS = {}

--misc

function LHS:write(data)
	if type(data)=="number" then
		data = love.data.pack("string", "<I1", data)
	end
	self.saveHandle:write(data)
end

function LHS:write2(data)
	self.saveHandle:write(love.data.pack("string", "<I2", data))
end

local function deHex(d)
	return love.data.decode("string","hex",d)
end

--writing

function LHS:writeHeaders()
	local h = self.rawHeaders
	
	self:write(h.prefix)
	self:write(h.campaignMarker)
	
	--settings list
	self:write(h.settingsList.amount)
	for _,entry in ipairs(h.settingsList.entries) do
		self:write(entry.id)
		self:write(entry.value)
	end
	
	--title
	for i=1,#h.title,1 do
		self:write(h.title[i])
		if i ~= #h.title then
			self:write("|")
		end
	end
	self:write(0x00)
	
	--zone and size
	self:write(h.zone)
	self:write(h.width)
	self:write(h.height)
	
	--DividerConstant (unknown), it's always this
	self:write(deHex("0000803F"))
end

function LHS:writeSingle(section)
	local c = self.rawContentEntries[section]
	self:write(self.tags[section])
	self:write2(c.nEntries)
	for _,v in ipairs(c.entries) do
		self:write2(v.id)
		self:write2(v.amount)
		for _,o in ipairs(v.subentries) do
			self:write(o.x)
			self:write(o.y)
		end
	end
end

function LHS:writeStructure(section)
	local c =self.rawContentEntries[section]
	self:write(self.tags[section])
	self:write2(c.nEntries)
	for _,v in ipairs(c.entries) do
		self:write(v.x)
		self:write(v.y)
		self:write2(v.id)
		self:write(v.length)
	end
end

function LHS:writeProperties(isPath)
	local c
	if isPath then
		c = self.rawContentEntries.pathProperties
	else
		c = self.rawContentEntries.objectProperties
		self:write(self.tags.properties)
	end
	self:write(c.nEntries)
	for _,entry in ipairs(c.entries) do
		self:write(entry.id)
		self:write2(entry.amount)
		for _,subentry in ipairs(entry.entries) do
			local format = P:getSaveFormat(entry.id)
			if format=="A" then
				self:write(subentry.value)
			elseif format=="B" then
				local v = subentry.value
				if v < 0 then
					--read: v = vfile - 65536
					--     vfile = v +65536
					v = v + 65536
				end
				self:write2(v)
			elseif format=="C" then
				local v = subentry.value
				local data = love.data.pack("string",self.floatFormat,v)
				self:write(data)
			elseif format=="D" then
				local v = subentry.value
				if v < 0 then
					--read: v = vfile - 256
					--     vfile = v + 256
					v = v + 256
				end
				self:write(v)
			else
				error("Invalid save format: "..entry.id..": "..format)
			end
			self:write2(subentry.amount)
			for _, subsubentry in ipairs(subentry.entries) do
				if isPath then
					self:write2(subsubentry)
				else
					self:write(subsubentry.x)
					self:write(subsubentry.y)
				end
			end
		end
	end
end

function LHS:writeHash()
	self:write(self.tags.hash)
	--get current file contents
	self.saveHandle:close()
	self.saveHandle:open("r")
	--self.saveHandle:seek(0)
	local contents = self.saveHandle:read()
	self.saveHandle:close()
	self.saveHandle:open("a")
	-- the cursor should be at the end again
	self:write(self.hash(contents))
	self:write(0)
end


function LHS.hash(input)
	local step = love.data.encode("string","base64",input) .. "598175".."0"
	step = love.data.encode("string","hex",love.data.hash("md5",step))
	step = step .. "AbunchoDANGNONSENSE9plusabigpileofhashsalsytiesooooooo901587"
	return love.data.encode("string","hex",love.data.hash("md5",step))
end


function LHS:writeAll()
	local file = NFS.newFile(self.path)
	local success,err = file:open("w")
	if not success then error(err) end
	self.saveHandle = file
	
	self:writeHeaders()
	
	self:writeSingle("singleForeground")
	self:writeStructure("foregroundRows")
	self:writeStructure("foregroundColumns")
	self:writeProperties(false)
	self:writeProperties(true)
	--RPS
	self:write(self.tags.repeatedPropertySets)
	self:write2(0) -- aka no RPS
	--Contained Objects
	self:writeSingle("containedObjects")
	
	self:writeSingle("paths")
	self:writeSingle("singleBackground")
	self:writeStructure("backgroundRows")
	self:writeStructure("backgroundColumns")
	self:writeHash()
	
	self.saveHandle:close()
	self.saveHandle = nil
end

return LHS
