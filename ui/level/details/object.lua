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
		self:addTextEntry("Element: "..o:getName().." ("..o.id..")")
		self:addTextEntry("Layer: ".. o.layer:sub(1,1):upper() .. o.layer:sub(2,-1) )
		self:addTextEntry("X: "..o.x)
		self:addTextEntry("Y: "..o.y)
		if o.contents then
			self:addTextEntry("Contents: "..o:getContents().." ("..o.contents..")")
		else
			self:addTextEntry("Contents: None")
		end
		self:addButtonEntry(
			"Delete",
			function()
				self.editor:delete(o)
			end,
			settings.dim.editor.details.object.buttonPadding
		)
		--properties
		self:addTextEntry("Properties:")
		for prop,value in pairs(o.properties) do
			local map = P:valueToMapping(prop,value)
			self:addTextEntry(P:getName(prop).." ("..prop.."): "..tostring(map).." ("..value..")",1)
		end
	end
end

return UI
