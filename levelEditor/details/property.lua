local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local UI = Class(require("ui.layout.list"))

function UI:initialize(propertyList,listStyle)
	UI.super.initialize(self,listStyle)
	
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
		self:addTextEntry(string.format("%s (%d)",P:getName(pl.propId),pl.propId),0)
		if pl.min==pl.max then
			self:addTextEntry(string.format("%s (%d)",P:valueToMapping(pl.propId,pl.min),pl.min),1)
		else
			self:addTextEntry(string.format("%s-%s (%d-%d)",P:valueToMapping(pl.propId,pl.min),P:valueToMapping(pl.propId,pl.max),pl.min,pl.max),1)
		end
		--[[self:addButtonEntry(
			"WIP",
			function()
				--
			end,
			settings.dim.editor.details.selection.property.buttonPadding
		)]]--
	end
end

return UI
