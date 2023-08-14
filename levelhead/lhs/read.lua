local LHS = {}

local P = require("levelhead.data.properties")
local NFS = require("libs.nativefs")

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--io

function LHS:loadFile(fullPath)
	local file = NFS.newFile(fullPath)
	local success,err = file:open("r")
	if not success then error(err) end
	self.path = fullPath
	---@type string
	self.raw = file:read()
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
	return love.data.unpack("<I1", self:getBytes(offset,1))
end

function LHS:getNumber2(offset)
	return love.data.unpack("<I2",self:getBytes(offset,2))
end

function LHS:verifyTag(section,offset)
	local tag = self.tags[section]
	local actual = self:getNumber1(offset)
	if actual ~= tag then
		error(string.format("Expected %s's tag 0x%02x at offset %d, found 0x%02x",section,tag,offset,actual),2)
	end
end

--data reading

function LHS:readHeaders()
	local h = {
		settingsList = {
			entries = {},
		},
	}
	self.rawHeaders = h
	
	--unknowns
	h.legacyVersion = self:getNumber2(1)
	h.levelheadVersion = love.data.unpack("<I4",self:getBytes(3,4))
	h.published = self:getNumber1(7)
	
	--settingsList
	h.settingsList.amount = self:getNumber1(8)
	local offset = 9
	h.settingsList.startOffset = offset
	for i=1,h.settingsList.amount,1 do
		table.insert(h.settingsList.entries,{
			id = self:getNumber1(offset),
			value = self:getNumber1(offset+1),
		})
		offset = offset + 2
	end
	h.settingsList.endOffset = offset-1
	
	--title
	h.titleStartOffset = offset
	h.title = {""}
	local segment = 1
	while true do
		local byte = self:getNumber1(offset)
		if byte == 0x00 then
			h.titleEndOffset = offset
			break
		elseif byte == 0x7C then
			segment = segment + 1
			h.title[segment] = ""
		else
			h.title[segment] = h.title[segment] .. string.char(byte)
		end
		offset = offset + 1
	end
	--zone
	h.zone = self:getNumber1(h.titleEndOffset+1)
	--level dimensions
	h.width = self:getNumber1(h.titleEndOffset+2)
	h.height = self:getNumber1(h.titleEndOffset+3)
	
	h.zoomLevel = love.data.unpack(self.floatFormat,self:getBytes(h.titleEndOffset+4,4))
	
	self.contentStartOffset = self.rawHeaders.titleEndOffset+8
end

function LHS:readSingle(section,prev)
	local c = {}
	self.rawContentEntries[section] = c
	--use prev as the name for the previous layer if it's a string, and as the direct start offset otherwise
	c.startOffset = prev and (self.rawContentEntries[prev].endOffset + 1) or self.contentStartOffset
	self:verifyTag(section,c.startOffset)
	c.nEntries = self:getNumber2(c.startOffset+1)
	c.entries = {}
	local offset = c.startOffset+3
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.startOffset = offset
		entry.id = self:getNumber2(offset)
		entry.amount = self:getNumber2(offset+2)
		entry.subentries={}
		for j=1,entry.amount,1 do
			local object = {}
			object.x = self:getNumber1(offset+2+j*2)
			object.y = self:getNumber1(offset+3+j*2)
			entry.subentries[j] = object
		end
		offset = offset + entry.amount*2 + 4
		entry.endOffset = offset - 1
		c.entries[i] = entry
	end
	c.endOffset = offset-1
end

function LHS:readStructure(section,prev)
	local c = {}
	self.rawContentEntries[section] = c
	c.startOffset = self.rawContentEntries[prev].endOffset+1
	self:verifyTag(section,c.startOffset)
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
		self:verifyTag("properties",c.startOffset)
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
				local value = self:getBytes(offset, 4)
				subentry.value = love.data.unpack(self.floatFormat,value)
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
				local subsubentry
				if isPath then
					subsubentry = self:getNumber2(offset)
				else
					subsubentry = {
						x = self:getNumber1(offset),
						y = self:getNumber1(offset+1)
					}
				end
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
	self:verifyTag("repeatedPropertySets",c.startOffset)
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
			local subentry = {
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
			local subentry = {
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
			local subentry = {
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
	self.rawContentEntries = {}
	self:readHeaders()
	self:readSingle("singleForeground")
	self:readStructure("foregroundRows","singleForeground")
	self:readStructure("foregroundColumns","foregroundRows")
	self:readProperties(false)
	self:readProperties(true)
	self:readRepeatedPropertySets()
	self:readSingle("containedObjects","repeatedPropertySets")
	self:readSingle("paths","containedObjects")
	self:readSingle("singleBackground","paths")
	self:readStructure("backgroundRows","singleBackground")
	self:readStructure("backgroundColumns","backgroundRows")
end

function LHS:getHash()
	return self:getBytes(self.raw:len()-32,32)
end

return LHS
