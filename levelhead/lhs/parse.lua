local Level = require("levelhead.level")
local Object = require("levelhead.objects.propertiesBase")

local LHS = {}

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

function LHS:parseHeaders()
	local raw = self.rawHeaders
	local w = Level:new(raw.width, raw.height)
	return w
end

function LHS:parseSingleForeground(w)
	local raw = self.rawContentEntries.singleForeground
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			local obj = Object:new(entry.id)
			w:addObject(obj, entry.objects[j].x + 1, w.height - entry.objects[j].y)
		end
	end
end

function LHS:parseForegroundRows(w)
	local raw = self.rawContentEntries.foregroundRows
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for x=0,entry.length,1 do
			local obj = Object:new(entry.id)
			w:addObject(obj, entry.x + x + 1, w.height - entry.y)
		end
	end
end

function LHS:parseForegroundColumns(w)
	local raw = self.rawContentEntries.foregroundColumns
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for y=0,entry.length,1 do
			local obj = Object:new(entry.id)
			w:addObject(obj, entry.x + 1, w.height - entry.y - y)
		end
	end
end

function LHS:parseProperties(w)
	local raw = self.rawContentEntries.singleObjectProperties
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			local subentry = entry.entries[j]
			for _,v in ipairs(subentry.entries) do
				--print(v.x, v.y)
				local obj = w.foreground:get(v.x + 1, w.height - v.y)
				obj:setPropertyRaw(entry.id, subentry.value)
			end
		end
	end
end

function LHS:parseAll()
	local w = self:parseHeaders()
	self:parseSingleForeground(w)
	self:parseForegroundRows(w)
	self:parseForegroundColumns(w)
	self:parseProperties(w)
	return w
end

return LHS
