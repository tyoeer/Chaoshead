local P = require("levelhead.data.properties")
local ParsedInput = require("ui.layout.parsedInput")

local function intParser(text)
	if text:match("%.") then
		return false, "Not a valid integer"
	else
		return tonumber(text), "Not a valid integer"
	end
end


local UI = Class(require("levelEditor.details.property"))

local theme = Settings.theme.details

function UI:initialize(propertyList, editor)
	UI.super.initialize(self,propertyList,theme.listStyle)
	self.editor = editor
	--self.input
end

function UI:addPropertyChanger(id, op)
	self:addButtonEntry(op, function()
		local v = self.input:getParsed()
		if v then
			if op=="/" and v==0 then
				MainUI:displayMessage("Can't divide by zero!")
			else
				self.editor:changeProperty(id, v, op)
				self:reload()
			end
		end
	end)
end

function UI:reloadWithWidth(width)
	self:resetList()
	if self.propertyList then
		local id = self.propertyList.propId
		local mapType = P:getMappingType(id)
		
		self:addTextEntry(self:getName()..":")
		if self.propertyList:isRangeProperty() then
			self:addTextEntry("Valid range: "..self:formatValue(P:getMin(id)).." - "..self:formatValue(P:getMax(id)))
		end
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
		
		if self.propertyList:isRangeProperty() then -- aka numerical
			if not self.input then
				self.input = ParsedInput:new(P:getSaveFormat(id)=="C" and tonumber or intParser, theme.inputStyle)
			end
			self:addUIEntry(self.input)
			self:addPropertyChanger(id, "=")
			self:addPropertyChanger(id, "+")
			self:addPropertyChanger(id, "-")
			self:addPropertyChanger(id, "*")
			self:addPropertyChanger(id, "/")
			
			if mapType=="Hybrid" then
				self:addTextEntry(" ") -- spacing between numerical values and special ones
			end
		end
		if mapType~="None" then
			for i = P:getMin(id), P:getMax(id) do
				if P:valueToMapping(id, i)==i then break end -- no mapped stuff here (or beyond)
				self:addButtonEntry(self:formatValue(i), function()
					self.editor:changeProperty(id, i)
					MainUI:removeModal()
				end)
			end
		end
		
		self:addTextEntry(" ") -- spacing between property values and dismiss button
	end
end

return UI