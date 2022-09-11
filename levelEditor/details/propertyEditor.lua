local P = require("levelhead.data.properties")
local ParsedInput = require("ui.layout.parsedInput")

local UI = Class("PropertyEditorUI",require("levelEditor.details.property"))

local theme = Settings.theme.details

function UI:initialize(propertyList, editor)
	self.input = ParsedInput:new(tonumber, theme.inputStyle)
	self.editor = editor
	self.filter = false
	UI.super.initialize(self,propertyList,theme.listStyle)
	self.lines = 0
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

function UI:addFilter(op)
	self:addButtonEntry(op, function()
		local v = self.input:getParsed()
		if v then
			-- TODO do thingy
			self:reload()
		end
	end)
end

function UI:reload()
	self:resetList()
	
	local id = self.propertyList.propId
	local mapType = P:getMappingType(id)
	
	self:addButtonEntry(self.filter and "Filtering" or "Editing",function()
		self.filter = not self.filter
		if self.filter then
			self.input = ParsedInput:new(function(str)
				return false, "TODO"
			end, theme.inputStyle)
		else
			self.input = ParsedInput:new(tonumber, theme.inputStyle)
		end
		self:reload()
	end)
	
	self:addTextEntry(self:getName()..":")
	if self.propertyList:isRangeProperty() then
		self:addTextEntry("Valid range: "..self:formatValue(P:getMin(id)).." - "..self:formatValue(P:getMax(id)))
	end
	local cur = "Currently:"
	local values = self:getValues()
	local both = cur.."  "..values
	local _, lines = love.graphics.getFont():getWrap(both, self.width)
	if #lines > 1 then
		self.lines = #lines + 1
		self:addTextEntry(cur)
		self:addTextEntry(values, 1)
	else
		self.lines = 1
		self:addTextEntry(both)
	end
	
	self:addTextEntry(" ") -- spacing
	if self.filter then
		self:addUIEntry(self.input)
		self:addFilter("==")
		self:addFilter("!=")
		self:addFilter(">")
		self:addFilter(">=")
		self:addFilter("<")
		self:addFilter("<=")
	else
		if self.propertyList:isRangeProperty() then -- aka numerical
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
				if mapType=="Hybrid" and P:valueToMapping(id, i)==i then break end -- no mapped stuff here (or beyond)
				self:addButtonEntry(self:formatValue(i), function()
					self.editor:changeProperty(id, i)
					MainUI:removeModal()
				end)
			end
		end
	end
	
	self:addTextEntry(" ") -- spacing between property values and dismiss button
	
	self:minimumHeightChanged()
end

function UI:getMinimumHeight(width)
	--use the method from the List class
	local base = UI.super.super.getMinimumHeight(self, width)
	local font = love.graphics.getFont()
	local lineHeight = font:getHeight() * font:getLineHeight() + self.style.entryMargin
	local _, lines = font:getWrap("Currently: "..self:getValues(), width)
	local n = #lines
	if #lines>1 then
		n = n + 1
	end
	return base + lineHeight*(n-self.lines)
end

return UI