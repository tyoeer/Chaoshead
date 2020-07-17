local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local UI = Class(require("ui.structure.list"))

function UI:initialize(object)
	UI.super.initialize(self)
	self.title = "Object Info"
	
	self.entryMargin = settings.dim.editor.details.object.entryMargin
	self.indentSize = settings.dim.editor.details.object.textEntryIndentSize
	
	self:setObject(object)
end

function UI:setObject(object)
	self.object = object
	self:reload()
end

function UI:reload()
	self:resetList()
	if self.object then
		local o = self.object
		self:addTextEntry("Element: "..E:getName(o.id).." ("..o.id..")")
		self:addTextEntry("X: "..o.x)
		self:addTextEntry("Y: "..o.y)
		self:addButtonEntry(
			"Delete",
			function()
				self.editor:delete(o)
			end,
			settings.dim.editor.details.object.buttonPadding
		)
		--properties
		if o.properties then
			self:addTextEntry("Properties:")
			for prop,value in pairs(o.properties) do
				local success, map = pcall(function()
					return P:valueToMapping(prop,value)
				end)
				self:addTextEntry(P:getName(prop).." ("..prop.."): "..tostring(map).." ("..value..")",1)
			end
		end
	end
end

return UI
