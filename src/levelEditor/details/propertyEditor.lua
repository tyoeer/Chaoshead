local P = require("levelhead.data.properties")
local ParsedInput = require("ui.widgets.parsedInput")

---@class PropertyEditorUI : PropertyDetailsUI
---@field super PropertyDetailsUI
---@field new fun(self, propertyList: PropertyList, popupUI: PropertyPopupUI, editor: LevelEditorUI, filter: boolean?): self
local UI = Class("PropertyEditorUI",require("levelEditor.details.property"))

local theme = Settings.theme.details

---@param editor LevelEditorUI
---@param popupUI PropertyPopupUI
function UI:initialize(propertyList, popupUI, editor, filter)
	self.editor = editor
	self.popupUI = popupUI
	
	self.filtering = filter or false
	if self.filtering then
		self.input = ParsedInput:new(function(str)
			if self.propertyList:isRangeProperty() then
				-- allow numbers
				local n = tonumber(str)
				if n then
					return n
				end
			end
			if P:isValidMapping(self.propertyList.propId, str) then
				return P:mappingToValue(self.propertyList.propId, str)
			end
			return false, "Entered value is neither a number nor a valid property value"
		end, theme.inputStyle)
	else
		self.input = ParsedInput:new(tonumber, theme.inputStyle)
		self.input:focusWithDefault(1)
	end
	
	self.lines = 0
	
	UI.super.initialize(self,propertyList,theme.listStyle)
	
	self.title = self.filtering and "Filter to" or "Edit"
end

function UI:addPropertyChanger(id, op)
	self:addButtonEntry(op, function()
		local v = self.input:getParsed()
		if v then
			if op=="/" and v==0 then
				MainUI:popup("Can't divide by zero!")
			else
				self.editor:changeProperty(id, v, op)
				self.popupUI:refreshPropertyList(self.propertyList) --also reloads
			end
		end
	end)
end

function UI:addFilter(op)
	self:addButtonEntry(op, function()
		local v = self.input:getParsed()
		if v then
			local propList, additionalDeselection = self.editor:filterProperty(self.propertyList.propId,v, op)
			if not propList then
				--filtered out every object with this modal
				MainUI:removeModal()
			end
			
			if additionalDeselection then
				MainUI:popup(
					"NOTE: Additional objects/path nodes were deselected because they were "
					.. "on the same tile as a path node/object that was filtered out"
				)
			end
			
			if propList then
				--propList has changed due to a selection refresh in editor:filterProperty()
				self.popupUI:refreshPropertyList(propList) --also reloads
			end
		end
	end)
end

function UI:reload()
	self:resetList()
	
	local id = self.propertyList.propId
	local mapType = P:getMappingType(id)
	
	self:addSeparator(false)
	
	self:addTextEntry(self:getName()..":")
	if self.propertyList:isRangeProperty() then
		self:addTextEntry("Valid range: "..self:formatValue(P:getMin(id)).." - "..self:formatValue(P:getMax(id)))
	end
	local cur = "Currently:"
	local values = self:getValues()
	local both = cur.."  "..values
	local _, lines = love.graphics.getFont():getWrap(both, self.width)
	if #lines > 1 then
		local _, lines = love.graphics.getFont():getWrap(values, self.width)
		self.lines = #lines + 1
		self:addTextEntry(cur)
		self:addTextEntry(values, 1)
	else
		self.lines = 1
		self:addTextEntry(both)
	end
	
	self:addSeparator(true)
	
	if self.filtering then
		self:addUIEntry(self.input)
		
		self:addSeparator(false)
		
		self:addFilter("==")
		self:addFilter("!=")
		if self.propertyList:isRangeProperty() then
			self:addFilter(">")
			self:addFilter(">=")
			self:addFilter("<")
			self:addFilter("<=")
		end
		
		self:addSeparator(false)
		
		if mapType~="None" then
			for i = P:getMin(id), P:getMax(id) do
				if mapType=="Hybrid" and P:valueToMapping(id, i)==i then break end -- no mapped stuff here (or beyond)
				self:addButtonEntry(self:formatValue(i), function()
					self.input:setRaw(P:valueToMapping(id, i))
				end)
			end
		end
	else
		if self.propertyList:isRangeProperty() then -- aka numerical
			self:addUIEntry(self.input)
			self:addPropertyChanger(id, "=")
			self:addPropertyChanger(id, "+")
			self:addPropertyChanger(id, "-")
			self:addPropertyChanger(id, "*")
			self:addPropertyChanger(id, "/")
			
			if mapType=="Hybrid" then
				self:addSeparator(true) -- between numerical values and special ones
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
	
	self:addSeparator(true)
	
	self:addButtonEntry("Dismiss", function()
		MainUI:removeModal()
	end)
	
	self:minimumHeightChanged()
end

function UI:getMinimumHeight(width)
	--use the method from the List class
	local base = UI.super.super.getMinimumHeight(self, width)
	local font = love.graphics.getFont()
	local lineHeight = font:getHeight() * font:getLineHeight()
	local _, lines = font:getWrap("Currently: "..self:getValues(), width)
	local n = #lines
	if n>1 then
		local _, lines = font:getWrap(self:getValues(), width)
		n = #lines + 1
		if self.lines==1 then
			--we used 1 text widget, but for this width should use 2
			base = base + self.style.entryMargin
		end
	elseif self.lines>1 then
		--we used 2 text widgets, but for this width should use only 1
		base = base - self.style.entryMargin
	end
	return base + lineHeight*(n-self.lines)
end

return UI