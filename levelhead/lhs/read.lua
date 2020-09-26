local LHS = {}
local bit = require("bit")

local P = require("levelhead.data.properties")

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--io

local defaultFiles = {
	--love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/m7n6j8/stages/-26.lhs",
	love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/m7n6j8/stages/-23.lhs",
	love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/m7n6j8/stages/-22.lhs",
	love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/xxqtsv/stages/-12.lhs",
}

function LHS:loadDefaultFile()
	for _,v in ipairs(defaultFiles) do
		local file,err = io.open(v,"rb")
		if file then
			self.path = v
			self.raw = file:read("*a")
			file:close()
			break
		end
	end
end

function LHS:loadFile(fullPath)
	local file,err = io.open(fullPath,"rb")
	if err then error(err) end
	self.path = fullPath
	self.raw = file:read("*a")
	file:close()
end

function LHS:reload()
	self:loadFile(self.path)
end

--misc

function LHS:getBytes(offset,length)
	return self.raw:sub(offset,offset+length-1)
end

function LHS:getNumber1(offset)
	return math.bytesToNumberLE(self:getBytes(offset,1))
end

function LHS:getNumber2(offset)
	return math.bytesToNumberLE(self:getBytes(offset,2))
end

--data reading

function LHS:readHeaders()
	local h = {}
	self.rawHeaders = h
	--misc before title
	h.music = self:getNumber1(10)
	h.mode = self:getNumber1(12)
	h.minPlayers = self:getNumber1(14)
	h.sharePowerups = self:getNumber1(16)>=1
	h.weather = self:getNumber1(18)>=1
	h.language = self:getNumber1(20)
	h.mpRespawnStyle = self:getNumber1(22)
	h.horCameraBoundary = self:getNumber1(24)>=1 -- true means it is bound by the level bounderies
	--title
	local i = 25
	local segment = 1
	h.title = {""}
	while true do
		local byte = self:getNumber1(i)
		if byte == 0x00 then
			self.titleEndOffset = i
			break
		elseif byte == 0x7C then
			segment = segment + 1
			h.title[segment] = ""
		else
			h.title[segment] = h.title[segment] .. string.char(byte)
		end
		i = i + 1
	end
	--zone
	h.zone = self:getNumber1(self.titleEndOffset+1)
	--level dimensions
	h.width = self:getNumber1(self.titleEndOffset+2)
	h.height = self:getNumber1(self.titleEndOffset+3)
end

function LHS:readSingleForeground()
	self.contentStartOffset = self.titleEndOffset+8
	local c = {}
	self.rawContentEntries.singleForeground = c
	c.nEntries = self:getNumber2(self.contentStartOffset+1)
	c.startOffset = self.contentStartOffset
	c.entries = {}
	local offset = c.startOffset+3
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.startOffset = offset
		entry.id = self:getNumber2(offset)
		entry.amount = self:getNumber2(offset+2)
		entry.objects={}
		for j=1,entry.amount,1 do
			local object = {}
			object.x = self:getNumber1(offset+2+j*2)
			object.y = self:getNumber1(offset+3+j*2)
			entry.objects[j] = object
		end
		offset = offset + entry.amount*2 + 4
		entry.endOffset = offset - 1
		c.entries[i] = entry
	end
	c.endOffset = offset-1
end

function LHS:readForegroundRows()
	local c = {}
	self.rawContentEntries.foregroundRows = c
	c.startOffset = self.rawContentEntries.singleForeground.endOffset+1
	c.nEntries = self:getNumber2(c.startOffset+1)
	c.entries = {}
	local offset = c.startOffset+3
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.startOffset = offset
		entry.x = self:getNumber1(offset)
		entry.y = self:getNumber1(offset+1)
		entry.id = self:getNumber2(offset+2)
		entry.length = self:getNumber1(offset+4)
		offset = offset + 5
		entry.endOffset = offset - 1
		c.entries[i] = entry
	end
	c.endOffset = offset-1
end

function LHS:readForegroundColumns()
	local c = {}
	self.rawContentEntries.foregroundColumns = c
	c.startOffset = self.rawContentEntries.foregroundRows.endOffset+1
	c.nEntries = self:getNumber2(c.startOffset+1)
	c.entries = {}
	local offset = c.startOffset+3
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.startOffset = offset
		entry.x = self:getNumber1(offset)
		entry.y = self:getNumber1(offset+1)
		entry.id = self:getNumber2(offset+2)
		entry.length = self:getNumber1(offset+4)
		offset = offset + 5
		entry.endOffset = offset - 1
		c.entries[i] = entry
	end
	c.endOffset = offset-1
end

function LHS:readProperties(isPath)
	--object properties
	local c = {}
	if isPath then
		self.rawContentEntries.pathProperties = c
		c.startOffset = self.rawContentEntries.objectProperties.endOffset
	else
		self.rawContentEntries.objectProperties = c
		c.startOffset = self.rawContentEntries.foregroundColumns.endOffset+1
	end
	c.nEntries = self:getNumber1(c.startOffset+1)
	c.entries = {}
	local offset = c.startOffset+2
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.startOffset = offset
		entry.id = self:getNumber1(offset)
		entry.amount = self:getNumber2(offset+1)
		entry.entries={}
		local format = P:getSaveFormat(entry.id)
		offset = offset + 3
		for j=1, entry.amount, 1 do
			local subentry = {}
			if format=="A" then
				subentry.value = self:getNumber1(offset)
				offset = offset + 1
			elseif format=="B" then
				subentry.value = self:getNumber2(offset)
				--checks if the most significant bit is set, because we need to negate it then
				-- 32768 = 2^15 - 1
				if subentry.value > 32767 then
					subentry.value = subentry.value - 65536
				end
				offset = offset + 2
			elseif format=="C" then
				--parse the float
				--see https://en.wikipedia.org/wiki/Single-precision_floating-point_format
				local value = math.bytesToNumberLE(self:getBytes(offset, 4))
				local sign = bit.rshift(value,31)==0 and 1 or -1
				local exponent = bit.band(bit.rshift(value,23),0xFF) - 127
				--local fraction = bit.rshift( bit.band(value,0x7FFFFF), 23)
				local fraction = bit.band(value, 0x7FFFFF) / 2^23
				--rounded because Lua appears to have floats that are more precise
				subentry.value = math.roundPrecision(sign * 2^exponent * (1+fraction), 0.0001)
				offset = offset + 4
			elseif format=="D" then
				subentry.value = self:getNumber1(offset)
				--checks if the most significant bit is set, because we need to negate it then
				-- 128 = 2^7
				if subentry.value > 128 then
					subentry.value = subentry.value - 256
				end
				offset = offset + 1
			else
				print("Error-------------------------------")
				local hex = love.data.encode("string","hex",self:getBytes(offset,8)):upper():gsub("(..)","%1 ")
				error("Illegal property save format: "..tostring(format).."\n"..entry.id.." : "..hex)
			end
			
			subentry.amount = self:getNumber2(offset)
			subentry.entries = {}
			offset = offset + 2
			for k=1, subentry.amount, 1 do
				local subsubentry = {
					x = self:getNumber1(offset),
					y = self:getNumber1(offset+1)
				}
				table.insert(subentry.entries, subsubentry)
				offset = offset + 2
			end
			table.insert(entry.entries, subentry)
		end
		
		entry.endOffset = offset - 1
		c.entries[i] = entry
	end
	c.endOffset = offset-1
end

function LHS:readRepeatedPropertySets()
	local c = {}
	self.rawContentEntries.repeatedPropertySets = c
	c.startOffset = self.rawContentEntries.pathProperties.endOffset + 1
	c.nEntries = self:getNumber2(c.startOffset+1)
	c.entries = {}
	local offset = c.startOffset + 3
	for i=1, c.nEntries, 1 do
		local entry = {
			sourceX = self:getNumber1(offset),
			sourceY = self:getNumber1(offset+1),
			startOffset = offset,
		}
		--rows
		entry.nRows = self:getNumber2(offset+2)
		entry.rows = {}
		offset = offset + 4
		for j=1, entry.nRows, 1 do
			subentry = {
				x = self:getNumber1(offset),
				y = self:getNumber1(offset+1),
				length = self:getNumber2(offset+2)
			}
			offset = offset + 4
			table.insert(entry.rows, subentry)
		end
		--columns
		entry.nColumns = self:getNumber2(offset)
		entry.columns = {}
		offset = offset + 2
		for j=1, entry.nColumns, 1 do
			subentry = {
				x = self:getNumber1(offset),
				y = self:getNumber1(offset+1),
				length = self:getNumber2(offset+2)
			}
			offset = offset + 4
			table.insert(entry.columns, subentry)
		end
		--single
		entry.nSingle = self:getNumber2(offset)
		entry.single = {}
		offset = offset + 2
		for j=1, entry.nSingle, 1 do
			subentry = {
				x = self:getNumber1(offset),
				y = self:getNumber1(offset+1)
			}
			offset = offset + 2
			table.insert(entry.single, subentry)
		end
		entry.endOffset = offset - 1
		table.insert(c.entries, entry)
	end
	c.endOffset = offset - 1
end

function LHS:readAll()
	self:readHeaders()
	self.rawContentEntries = {}
	self:readSingleForeground()
	self:readForegroundRows()
	self:readForegroundColumns()
	self:readProperties(false)
	self:readProperties(true)
	self:readRepeatedPropertySets()
end

return LHS
