local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local UI = Class(require("ui.structure.list"))

function UI:initialize(node)
	UI.super.initialize(self)
	self.title = "Node Info"
	
	self.entryMargin = settings.dim.editor.details.pathNode.entryMargin
	self.indentSize = settings.dim.editor.details.pathNode.textEntryIndentSize
	
	self:setPathNode(node)
end

function UI:setPathNode(node)
	self.node = node
	self:reload()
end

function UI:reload()
	self:resetList()
	if self.node then
		local n = self.node
		self:addTextEntry("X: "..n.x)
		self:addTextEntry("Y: "..n.y)
		self:addButtonEntry(
			"Delete",
			function()
				self.editor:delete(n)
			end,
			settings.dim.editor.details.object.buttonPadding
		)
		local p = n.path
		self:addTextEntry("Properties:")
		for prop,value in pairs(p.properties) do
			local success, map = pcall(function()
				return P:valueToMapping(prop,value)
			end)
			self:addTextEntry(P:getName(prop).." ("..prop.."): "..tostring(map).." ("..value..")",1)
		end
	end
end

return UI
