local LHS = {}

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

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

function LHS:readAll()
	self:readHeaders()
	self.rawContentEntries = {}
	self:readSingleForeground()
	self:readForegroundRows()
	self:readForegroundColumns()
end

return LHS
