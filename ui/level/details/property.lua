local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local UI = Class(require("ui.structure.list"))

function UI:initialize(propertyList)
	UI.super.initialize(self)
	self.title = "Property Info"
	
	self.entryMargin = settings.dim.editor.details.selection.property.entryMargin
	self.indentSize = settings.dim.editor.details.selection.property.textEntryIndentSize
	
	self:setPropertyList(propertyList)
end

function UI:setPropertyList(propertyList)
	self.propertyList = propertyList
	self:reload()
end

function UI:reload()
	self:resetList()
	if self.propertyList then
		local pl = self.propertyList
		self:addTextEntry(P:getName(pl.propId).." ("..pl.propId..")",0)
		self:addTextEntry(P:valueToMapping(pl.propId,pl.min).." - "..P:valueToMapping(pl.propId,pl.max),1)
		self:addTextEntry("("..pl.min.." - "..pl.max..")",1)
		self:addButtonEntry(
			"WIP",
			function()
				--
			end,
			settings.dim.editor.details.selection.property.buttonPadding
		)
	end
end

return UI
