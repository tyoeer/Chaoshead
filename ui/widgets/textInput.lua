local Button = require("ui.widgets.button")
local Text = require("ui.widgets.text")

---@class TextInputStyle
---@field textColor number[]
---@field backgroundColor number[]
---@field borderColor number[]
---@field caretColor number[]
---@field padding number

---@class TextInputUI : ProxyUI
---@field super ProxyUI
---@field new fun(self: self, onChange: fun(), style: TextInputStyle): self
local UI = Class("TextInputUI",require("ui.base.proxy"))

function UI:initialize(onChange, style)
	self:setStyleRaw(style)
	self.onChange = onChange
	self.focussed = false
	-- self.timer
	
	self.textDisplay = Text:new(" ", 0, self:getTextStyle())
	
	-- can't use :setText() because that one also call the onChange callback, which we don't want to call while initialising
	self.left = "" -- text to the left of the cursor
	self.right = "" -- text to the right of the cursor
	self:updateDisplayText()
	
	local b = Button:new(self.textDisplay, function() self:grabFocus() end, self:getButtonStyle())
	UI.super.initialize(self, b)
end

---@param style TextInputStyle
function UI:setStyleRaw(style)
	if not style then
		error("No style specified!",2)
	end
	if not style.textColor then
		error("Text color not specified!",2)
	end
	if not style.backgroundColor then
		error("Background color not specified")
	end
	if not style.borderColor then
		error("Border color not specified")
	end
	if not style.caretColor then
		error("Caret color not specified")
	end
	if not style.padding then
		error("Padding not specified")
	end
	self.style = style
end

function UI:setStyle(style)
	self:setStyleRaw(style)
	self.textDisplay:setStyle(self:getTextStyle())
	self.child:setStyle(self:getButtonStyle())
end

function UI:getTextStyle()
	return {
		color = self.style.textColor,
		horAlign = "left",
		verAlign = "center",
	}
end

function UI:getButtonStyle()
	return {
		padding = self.style.padding,
		border = true,
		normal = {
			backgroundColor = self.style.backgroundColor,
			borderColor = self.style.borderColor,
		},
		hover = {
			backgroundColor = self.style.backgroundColor,
			borderColor = self.style.borderColor,
		},
	}
end

function UI:changed()
	self.onChange()
	self:updateDisplayText()
end

function UI:updateDisplayText()
	local text = self:getText()
	if text=="" then
		self.textDisplay:setText(" ")
	else
		self.textDisplay:setText(text)
	end
end

function UI:grabFocus()
	self.focussed = true
	self.timer = 0
end

---@param text string
function UI:setText(text)
	self.left = text
	self.right = ""
	self:changed()
end

function UI:getText()
	return self.left .. self.right
end


function UI:getMinimumHeight(width)
	return self.child:getMinimumHeight(width)
end


-- EVENTS


function UI:onUpdate()
	if self.focussed then
		self.timer = self.timer + 1
	end
end

function UI:onDraw()
	if self.focussed and self.timer % 60 < 30 then
		local x = self.textDisplay.font:getWidth(self.left) + self.textDisplay.x
		if self.left~="" and self.right=="" then
			x = x + 1
		end
		love.graphics.setColor(self.style.caretColor)
		love.graphics.line(x,self.textDisplay.y, x,self.textDisplay.y+self.textDisplay.height)
	end
end

function UI:onTextInput(input)
	if self.focussed then
		self.left = self.left .. input
		self:changed()
		self.timer = 0
	end
end

function UI:onInputActivated(name,group,_isCursorBound)
	if group=="textInput" then
		if name=="left" then
			self.right = self.left:sub(-1) .. self.right
			self.left = self.left:sub(1,-2)
		elseif name=="right" then
			self.left = self.left .. self.right:sub(1,1)
			self.right = self.right:sub(2)
		elseif name=="removeLeft" then
			self.left = self.left:sub(1,-2)
			self:changed()
		elseif name=="removeRight" then
			self.right = self.right:sub(2)
			self:changed()
		elseif name=="defocusDetection" then
			-- this one isn't cursor bound, so will trigger when clicked outside the textbox
			if self.timer~=0 then
				self.focussed = false
				return -- dont reset timer
			end
		end
		self.timer = 0
	end
end

function UI:onMouseMoved(x,y,_dx,_dy)
	if x > 0 and x < self.width and y > 0 and y < self.height then
		love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"))
	else
		love.mouse.setCursor()
	end
end

return UI