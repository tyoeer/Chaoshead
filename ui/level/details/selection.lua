local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local PUI = require("ui.level.details.property")

local UI = Class(require("ui.structure.list"))

function UI:initialize(tracker)
	UI.super.initialize(self)
	self.title = "Selection"
	
	self.entryMargin = settings.dim.editor.details.selection.entryMargin
	self.indentSize = settings.dim.editor.details.selection.textEntryIndentSize
	
	self:setSelectionTracker(tracker)
end

function UI:setSelectionTracker(tracker)
	self.selection = tracker
	self:reload()
end

function UI:reload()
	self:resetList()
	local s = self.selection
	--counts + filters
	do
		self:addTextEntry("Tiles: "..s.mask.nTiles)
		self:addButtonEntry("Deselect",function()
			self.editor:deselect()
		end)
		if s:hasLayer("foreground") then
			self:addTextEntry("Foreground objects: "..s.contents.nForeground)
			self:addButtonEntry("Deselect foreground",function()
				self.editor:removeSelectionLayer("foreground")
			end)
		end
		if s:hasLayer("background") then
			self:addTextEntry("Background objects: "..s.contents.nBackground)
			self:addButtonEntry("Deselect background",function()
				self.editor:removeSelectionLayer("background")
			end)
		end
		if s:hasLayer("pathNodes") then
			self:addTextEntry("Path nodes: "..s.contents.nPathNodes)
			self:addButtonEntry("Deselect path nodes",function()
				self.editor:removeSelectionLayer("pathNodes")
			end)
		end
	end
	self:addButtonEntry("Delete",function()
		self.editor:deleteSelection()
	end)
	local c = s.contents
	--add a divider
	self:addTextEntry(" ",0)
	--objects with unknown properties
	do
		local u = c.unknownProperties
		if u:getTop()~=nil then
			local text = "The objects at the following positions are missing proper property data and had to use fallbacks:"
			for obj in u:iterate() do
				text = text..string.format(" (%d,%d)", obj.x, obj.y)
			end
			self:addTextEntry(text)
		end
	end
	--properties
	for _,pl in pairs(c.properties) do
		self:addUIEntry(PUI:new(pl))
	end
end

return UI
