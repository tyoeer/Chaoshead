local P = require("levelhead.data.properties")

local UI = Class(require("levelEditor.details.property"))

function UI:initialize(propertyList,listStyle, editor)
	UI.super.initialize(self,propertyList,listStyle)
	self.editor = editor
end

function UI:reloadWithWidth(width)
	self:resetList()
	if self.propertyList then
		self:addTextEntry(self:getName()..":")
		local cur = "Currently:"
		local values = self:getValues()
		local both = cur.."  "..values
		local _, lines = love.graphics.getFont():getWrap(both, width)
		if #lines > 1 then
			self:addTextEntry(cur)
			self:addTextEntry(values, 1)
		else
			self:addTextEntry(both)
		end
		self:addTextEntry(" ") -- spacing
		local id = self.propertyList.propId
		for i = P:getMin(id), P:getMax(id) do
			local val = P:valueToMapping(id, i)
			self:addButtonEntry(val, function()
				self.editor:setProperty(id, i)
				MainUI:removeModal()
			end)
		end
		self:addTextEntry(" ") -- spacing between property values and dismiis button
	end
end

return UI