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
		local byte = self:getNumber(i)
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
	h.width = self:getNumber(self.titleEndOffset+2)
	h.height = self:getNumber(self.titleEndOffset+3)
end

function LHS:readSingleForeground()
	self.contentStartOffset = self.titleEndOffset+8
	local c = {}
	self.rawContentEntries.singleForeground = c
	c.nEntries = self:getNumber(self.contentStartOffset+1)
	c.startOffset = self.contentStartOffset
	c.entries = {}
	local offset = c.startOffset+3
	for i=1,c.nEntries,1 do
		local entry = {}
		entry.id = self:getNumber(offset)
		entry.amount = self:getNumber(offset+2)
		entry.objects={}
		for j=1,entry.amount,1 do
			local item = {}
			item.x = self:getNumber(offset+2+j*2)
			item.y = self:getNumber(offset+3+j*2)
			entry.objects[j] = item
		end
		offset = offset + entry.amount*2 + 4
		c.entries[i] = entry
	end
	c.endOffset = offset
end

function LHS:readAll()
	self:readHeaders()
	self.rawContentEntries = {}
	self:readSingleForeground()
end

return LHS
