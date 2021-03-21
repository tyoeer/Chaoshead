local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local UI = Class(require("ui.structure.list"))

function UI:initialize(tracker)
	UI.super.initialize(self)
	self.title = "Object Info"
	
	self.entryMargin = settings.dim.editor.details.object.entryMargin
	self.indentSize = settings.dim.editor.details.object.textEntryIndentSize
	
	self:setSelectionTracker(tracker)
end

function UI:setSelectionTracker(tracker)
	self.selection = tracker
	self:reload()
end

function UI:reload()
	self:resetList()
	local s = self.selection
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

return UI
