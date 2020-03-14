local LHS = {}

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

function LHS:readHeaders()
	local h = {}
	self.rawHeaders = h
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
			local item = {}
			item.x = self:getNumber1(offset+2+j*2)
			item.y = self:getNumber1(offset+3+j*2)
			entry.objects[j] = item
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
	c.nEntries = self:getNumber2(c.startOffset)
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

function LHS:readAll()
	self:readHeaders()
	self.rawContentEntries = {}
	self:readSingleForeground()
	self:readForegroundsRows()
end

return LHS
