local LHS = {}
local bit = require("bit")

local P = require("levelhead.data.properties"):new()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--io

local defaultFiles = {
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

function LHS:readSingleProperties(isPath)
	--object properties
	local c = {}
	if isPath then
		self.rawContentEntries.singlePathProperties = c
		c.startOffset = self.rawContentEntries.singleObjectProperties.endOffset
		c.nEntries = self:getNumber1(c.startOffset+1)
	else
		self.rawContentEntries.singleObjectProperties = c
		c.startOffset = self.rawContentEntries.foregroundColumns.endOffset+1
		c.nEntries = self:getNumber1(c.startOffset+1)
	end
	c.entries = {}
	local offset = c.startOffset+2
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.startOffset = offset
		entry.id = self:getNumber1(offset)
		entry.amount = self:getNumber2(offset+1)
		entry.entries={}
		local format = P:getSaveFormat(entry.id)
		if format=="A" then
			for j=0,entry.amount-1,1 do
				local subentry = {}
				subentry.value = self:getNumber1(offset+j*5+3)
				subentry.x = self:getNumber1(offset+j*5+6)
				subentry.y = self:getNumber1(offset+j*5+7)
				entry.entries[j+1] = subentry
			end
			offset = offset + entry.amount*5 + 3
		elseif format=="B" then
			for j=0,entry.amount-1,1 do
				local subentry = {}
				subentry.value = self:getNumber2(offset+j*5+3)
				--checks if the most significant bit is set
				-- 32768 = 2^15
				if subentry.value > 32768 then
					subentry.value = subentry.value - 65536
				end
				subentry.x = self:getNumber1(offset+j*5+7)
				subentry.y = self:getNumber1(offset+j*5+8)
				entry.entries[j+1] = subentry
			end
			offset = offset + entry.amount*6 + 3
		elseif format=="C" then
			for j=0,entry.amount-1,1 do
				local subentry = {}
				--parse the float
				--see https://en.wikipedia.org/wiki/Single-precision_floating-point_format
				do
					local value = math.bytesToNumberLE(self:getBytes(offset+j*5+3, 4))
					local sign = bit.rshift(value,31)==0 and 1 or -1
					local exponent = bit.band(bit.rshift(value,23),0xFF) - 127
					local fraction = bit.band(value,0x7FFFFF) / (2^23)
					subentry.value = math.roundPrecision(sign * 2^exponent * (1+fraction), 0.01)
				end
				subentry.x = self:getNumber1(offset+j*5+9)
				subentry.y = self:getNumber1(offset+j*5+10)
				entry.entries[j+1] = subentry
			end
			offset = offset + entry.amount*8 + 3
		else
			print("Error-------------------------------")
			print("prop.id",entry.id)
			error("Illegal property save format: "..format)
		end
		entry.endOffset = offset - 1
		c.entries[i] = entry
	end
	c.endOffset = offset-1
end

function LHS:readAll()
	self:readHeaders()
	self.rawContentEntries = {}
	self:readSingleForeground()
	self:readForegroundRows()
	self:readForegroundColumns()
	self:readSingleProperties(false)
	self:readSingleProperties(true)
end

return LHS
