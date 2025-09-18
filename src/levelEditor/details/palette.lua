local E = require("levelhead.data.elements")
local Clipboard = require("tools.clipboard")
local World = require("levelhead.level.world")
local Object = require("levelhead.level.object")
local Mask = require("tools.selection.mask")

local UI = Class("PaletteDetailsUI",require("ui.tools.details"))

local elemList = {}
local tmpWorld = World:new()

do
	for id=0, E:getHighestID() do
		table.insert(elemList, {
			id = id,
			name = E:getName(id)
		})
	end
	
	table.insert(elemList, {
		id = -10,
		name = "Path Node"
	})
	
	table.sort(elemList, function(a,b)
		local aSize, aName = a.name:match("(%d+x%d+) (.+)")
		if not aName then aName = a.name end
		local bSize, bName = b.name:match("(%d+x%d+) (.+)")
		if not bName then bName = b.name end
		if aName==bName then
			if not aSize and not bSize then
				return a.id < b.id
			elseif not aSize then
				return true
			elseif not bSize then
				return false
			else
				return aSize < bSize
			end
		else
			return aName < bName
		end
	end)
end

function UI:initialize(level,editor)
	self.editor = editor
	self.level = level
	
	UI.super.initialize(self)
	self.title = "Palette"
end

function UI:onReload(list,level)
	if level then
		self.level = level
	else
		level = self.level
	end
	list:resetList()
	
	for _, elem in ipairs(elemList) do
		list:addButtonEntry(elem.name, function()
			local mask = Mask:new()
			mask:setLayerEnabled("foreground", false)
			mask:setLayerEnabled("background", false)
			mask:setLayerEnabled("pathNodes", false)
			local width = E:getWidth(elem.id)
			if width=="$UnknownWidth" then width = 1 end
			local height = E:getHeight(elem.id)
			if height=="$UnknownHeight" then height = 1 end
			for x=1,width do
				for y=1,height do
					mask:add(x,y)
				end
			end
			
			for obj in tmpWorld.objects:iterate() do
				tmpWorld:removeObject(obj)
			end
			
			local x, y = math.ceil(width/2), height - math.ceil(height/2) + 1
			local layer = E:getLayer(elem.id)
			if layer=="$UnknownLayer" then
				if elem.id==-10 then
					mask:setLayerEnabled("pathNodes", true)
					tmpWorld:newPath():append(x,y)
				else
					mask:setLayerEnabled("foreground", true)
					tmpWorld:addForegroundObject(Object:new(elem.id), x,y)
				end
			else
				mask:setLayerEnabled(E:getLayer(elem.id):lower(), true)
				tmpWorld:addObject(Object:new(elem.id), x,y)
			end
			
			local hand = Clipboard:new(tmpWorld, mask)
			self.editor:hold(hand)
		end)
	end
end

return UI
