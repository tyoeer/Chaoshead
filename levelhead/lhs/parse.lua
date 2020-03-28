local Level = require("levelhead.level")
local Object = require("levelhead.objects.base")

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
			local obj = Object:new(
				entry.id,
				entry.objects[j].x + 1,
				w.height - entry.objects[j].y
			)
			w:addObject(obj)
		end
	end
end

function LHS:parseForegroundRows(w)
	local raw = self.rawContentEntries.foregroundRows
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for x=0,entry.length,1 do
			local obj = Object:new(
				entry.id,
				entry.x + x + 1,
				w.height - entry.y
			)
			w:addObject(obj)
		end
	end
end

function LHS:parseForegroundColumns(w)
	local raw = self.rawContentEntries.foregroundColumns
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for y=0,entry.length,1 do
			local obj = Object:new(
				entry.id,
				entry.x + 1,
				w.height - entry.y - y
			)
			w:addObject(obj)
		end
	end
end

function LHS:parseAll()
	local w = self:parseHeaders()
	self:parseSingleForeground(w)
	self:parseForegroundRows(w)
	self:parseForegroundColumns(w)
	return w
end

return LHS
