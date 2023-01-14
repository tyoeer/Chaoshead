local Level = require("levelhead.level.level")
local Settings = require("levelhead.level.settings")
local Object = require("levelhead.level.object")
local E = require("levelhead.data.elements")

local LHS = {}

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--


function LHS:parseHeaders()
	local raw = self.rawHeaders
	
	local settings = Settings:new()
	settings.zone = raw.zone
	settings.prefix = raw.prefix
	settings.campaignMarker = raw.campaignMarker
	
	--title
	for k,v in pairs(raw.title) do
		settings.title[k] = v
	end
	
	--settings list
	for _,v in ipairs(raw.settingsList.entries) do
		if self.settingsListBooleans[v.id] then
			settings[self.settingsList[v.id]] = v.value>=1
		else
			settings[self.settingsList[v.id]] = v.value
		end
	end
	
	return settings, raw.width, raw.height
end


function LHS:parseSingleForeground(w)
	local raw = self.rawContentEntries.singleForeground
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			local obj = Object:new(entry.id)
			w:addObject(obj, w:fileToWorldX(entry.subentries[j].x), w:fileToWorldY(entry.subentries[j].y))
		end
	end
end

function LHS:parseForegroundRows(w)
	local raw = self.rawContentEntries.foregroundRows
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		local width = E:getWidth(entry.id)
		for x=0,entry.length,1 do
			local obj = Object:new(entry.id)
			w:addObject(obj, w:fileToWorldX(entry.x + width*x), w:fileToWorldY(entry.y))
		end
	end
end

function LHS:parseForegroundColumns(w)
	local raw = self.rawContentEntries.foregroundColumns
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		local height = E:getHeight(entry.id)
		for y=0,entry.length,1 do
			local obj = Object:new(entry.id)
			w:addObject(obj, w:fileToWorldX(entry.x), w:fileToWorldY(entry.y + height*y))
		end
	end
end

function LHS:parseObjectProperties(w)
	local raw = self.rawContentEntries.objectProperties
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			local subentry = entry.entries[j]
			for _,v in ipairs(subentry.entries) do
				local obj = w.foreground:get(w:fileToWorldX(v.x), w:fileToWorldY(v.y))
				obj:setPropertyRaw(entry.id, subentry.value)
			end
		end
	end
end

local function copyProperties(src,target)
	for k,v in pairs(src.properties) do
		target.properties[k] = v
	end
end
function LHS:parseRepeatedPropertySets(w)
	local raw = self.rawContentEntries.repeatedPropertySets
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		local src = w.foreground[w:fileToWorldX(entry.sourceX)][w:fileToWorldY(entry.sourceY)]
		--rows
		for _,row in ipairs(entry.rows) do
			for j=0, row.length, 1 do
				local target = w.foreground[w:fileToWorldX(row.x+j)][w:fileToWorldY(row.y)]
				copyProperties(src, target)
			end
		end
		--columns
		for _,col in ipairs(entry.columns) do
			for j=0, col.length, 1 do
				local target = w.foreground[w:fileToWorldX(col.x)][w:fileToWorldY(col.y+j)]
				copyProperties(src, target)
			end
		end
		--single
		for _,single in ipairs(entry.single) do
			local target = w.foreground[w:fileToWorldX(single.x)][w:fileToWorldY(single.y)]
			copyProperties(src, target)
		end
	end
end

function LHS:parseContainedObjects(w)
	local raw = self.rawContentEntries.containedObjects
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			--directly set internal value for performance
			w.foreground[ w:fileToWorldX(entry.subentries[j].x) ][ w:fileToWorldY(entry.subentries[j].y) ].contents = entry.id
		end
	end
end

function LHS:parsePaths(w)
	local idMap = {}
	local raw = self.rawContentEntries.paths
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		local p = w:newPath()
		for j=1,entry.amount,1 do
			local x, y = w:fileToWorldX(entry.subentries[j].x), w:fileToWorldY(entry.subentries[j].y)
			w.pathNodes[x][y] = nil -- If there's already a pth node, it would get deleted. This way we half-support overlapping path nodes.
			p:append(x, y)
		end
		idMap[entry.id] = p
	end
	return idMap
end

function LHS:parsePathProperties(pathIdMap)
	local raw = self.rawContentEntries.pathProperties
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			local subentry = entry.entries[j]
			for _,v in ipairs(subentry.entries) do
				pathIdMap[v]:setPropertyRaw(entry.id, subentry.value)
			end
		end
	end
end

function LHS:parseSingleBackground(w)
	local raw = self.rawContentEntries.singleBackground
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		for j=1,entry.amount,1 do
			local obj = Object:new(entry.id)
			w:addBackgroundObject(obj, w:fileToWorldX(entry.subentries[j].x), w:fileToWorldY(entry.subentries[j].y))
		end
	end
end

function LHS:parseBackgroundRows(w)
	local raw = self.rawContentEntries.backgroundRows
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		local width = E:getWidth(entry.id)
		for x=0,entry.length,1 do
			local obj = Object:new(entry.id)
			w:addBackgroundObject(obj, w:fileToWorldX(entry.x + width*x), w:fileToWorldY(entry.y))
		end
	end
end

function LHS:parseBackgroundColumns(w)
	local raw = self.rawContentEntries.backgroundColumns
	for i=1,raw.nEntries,1 do
		local entry = raw.entries[i]
		local height = E:getHeight(entry.id)
		for y=0,entry.length,1 do
			local obj = Object:new(entry.id)
			w:addBackgroundObject(obj, w:fileToWorldX(entry.x), w:fileToWorldY(entry.y + height*y))
		end
	end
end

function LHS:parseAll()
	local settings, width, height = self:parseHeaders()
	local level = Level:new()
	level.left, level.top = 1, 1
	level.right, level.bottom = width, height
	level.settings = settings
	self:parseSingleForeground(level)
	self:parseForegroundRows(level)
	self:parseForegroundColumns(level)
	self:parseObjectProperties(level)
	self:parseRepeatedPropertySets(level)
	self:parseContainedObjects(level)
	local idMap = self:parsePaths(level)
	self:parsePathProperties(idMap)
	self:parseSingleBackground(level)
	self:parseBackgroundRows(level)
	self:parseBackgroundColumns(level)
	return level
end

return LHS
