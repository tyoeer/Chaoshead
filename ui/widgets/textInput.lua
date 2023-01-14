local Button = require("ui.widgets.button")
local Text = require("ui.widgets.text")

---@class TextInputStyle
---@field textColor number[]
---@field backgroundColor number[]
---@field borderColor number[]
---@field caretColor number[]
---@field selectionColor number[]
---@field selectedTextColor number[]
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
	
	-- can't use :setText() because that one also calls the onChange callback, which we don't want to call while initialising
	self.left = "" -- text to the left of the cursor
	self.right = "" -- text to the right of the cursor
	self.selection = nil -- selected text; inbetween left and right
	self.cursorRightOfSelection = false
	self:updateDisplayText()
	
	local b = Button:new(
		self.textDisplay,
		function()
			self:grabFocus()
			self:cursorToMouse()
		end,
		self:getButtonStyle(),
		true
	)
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
	if not style.selectionColor then
		error("Selection color not specified")
	end
	if not style.selectedTextColor then
		error("Selected text color not specified")
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

function UI:defocus()
	self.focussed = false
	self.left = self:getText()
	self.selection = nil
	self.right = ""
end

---@param text string
function UI:setText(text)
	self.left = text
	self.right = ""
	self:changed()
end

function UI:getText()
	return self.left .. (self.selection or "") .. self.right
end


function UI:focusWithDefault(default)
	self:grabFocus()
	self.cursorRightOfSelection = true
	self.selection = default
	self.left = ""
	self.right = ""
	self:updateDisplayText()
end

function UI:getCurrentCaretPos()
	if self.selection and self.cursorRightOfSelection then
		return #self.left + #self.selection
	else
		return #self.left
	end
end

function UI:roundToChar(dx, checkFrom)
	if not checkFrom then
		checkFrom = 1
	end
	
	local text = self:getText()
	local bestPos = 1
	local bestErr = math.abs(dx)
	local lastErr = dx
	
	for i=checkFrom, text:len() do
		local pre = text:sub(1,i)
		local x = self.textDisplay.font:getWidth(pre)
		local err = math.abs(dx-x)
		
		if err > lastErr then
			--error is increasing, we're beyond the cursor, we won't find anything better here
			break
		end
		
		if err < bestErr then
			bestPos = i
			bestErr = err
		end
		
		lastErr = err
	end
	
	return bestPos
end

function UI:cursorToMouse()
	local pos = self:roundToChar(self.textDisplay:getMouseX())
	
	while pos > self:getCurrentCaretPos() do
		self:moveRight()
	end
	while pos < self:getCurrentCaretPos() do
		self:moveLeft()
	end
end


function UI:getLeftOfCursorName()
	if self.selection then
		if self.cursorRightOfSelection then
			return "selection"
		else
			return "left"
		end
	else
		return "left"
	end
end

function UI:getLeftOfCursor()
	return self[self:getLeftOfCursorName()]
end

function UI:getRightOfCursorName()
	if self.selection then
		if self.cursorRightOfSelection then
			return "right"
		else
			return "selection"
		end
	else
		return "right"
	end
end

function UI:getRightOfCursor()
	return self[self:getRightOfCursorName()]
end

--- Moves the first character of `from` one string to the left (adds it at the end)
function UI:moveCharLeft(from)
	local to
	if from=="selection" then
		to = "left"
	elseif from=="right" then
		to = self.selection and "selection" or "left"
	end
	
	self[to] = self[to] .. self[from]:sub(1,1)
	self[from] = self[from]:sub(2)
end

--- Moves the last character of `from` one string to the right (adds it at the start)
function UI:moveCharRight(from)
	local to
	if from=="selection" then
		to = "right"
	elseif from=="left" then
		to = self.selection and "selection" or "right"
	end
	
	self[to] = self[from]:sub(-1) .. self[to]
	self[from] = self[from]:sub(1,-2)
end

function UI:moveLeft(selectOverride)
	if self.selection then
		if Input.isActive("selectModifier", "textInput") or selectOverride then
			self:moveCharRight(self:getLeftOfCursorName())
			if self.selection=="" then
				self.selection = nil
			end
		else
			self.right = self.selection .. self.right
			self.selection = nil
		end
	else
		if Input.isActive("selectModifier", "textInput") or selectOverride then
			self.selection = ""
			self.cursorRightOfSelection = false
		end
		self:moveCharRight("left")
	end
end

function UI:moveRight(selectOverride)
	if self.selection then
		if Input.isActive("selectModifier", "textInput") or selectOverride then
			self:moveCharLeft(self:getRightOfCursorName())
			if self.selection=="" then
				self.selection = nil
			end
		else
			self.left = self.left .. self.selection
			self.selection = nil
		end
	else
		if Input.isActive("selectModifier", "textInput") or selectOverride then
			self.selection = ""
			self.cursorRightOfSelection = true
		end
		self:moveCharLeft("right")
	end
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
	if self.focussed then
		if self.selection then
			local startX = self.textDisplay.font:getWidth(self.left) + self.textDisplay.x
			local width = self.textDisplay.font:getWidth(self.selection)
			love.graphics.setColor(self.style.selectionColor)
			love.graphics.rectangle("fill", startX, self.textDisplay.y, width, self.textDisplay.height)
			love.graphics.setColor(self.style.selectedTextColor)
			love.graphics.print(self.selection, startX, self.textDisplay.y)
		end
		
		-- caret
		if self.timer % 60 < 30 then
			local textBeforeCursor = self.left
			if self.selection and self.cursorRightOfSelection then
				textBeforeCursor = textBeforeCursor .. self.selection
			end
			
			local x = self.textDisplay.font:getWidth(textBeforeCursor) + self.textDisplay.x
			if self.left~="" and self.right=="" then
				x = x + 1
			end
			love.graphics.setColor(self.style.caretColor)
			love.graphics.line(x,self.textDisplay.y, x,self.textDisplay.y+self.textDisplay.height)
		end
	end
end

function UI:onTextInput(input)
	if self.focussed then
		self.selection = nil
		self.left = self.left .. input
		self:changed()
		self.timer = 0
	end
end

function UI:onInputActivated(name,group,_isCursorBound)
	if group=="textInput" then
		if name=="left" then
			if Input.isActive("wordModifier", "textInput") then
				while self:getLeftOfCursor():match("%W$") do
					self:moveLeft()
				end
				while self:getLeftOfCursor():match("%w$") do
					self:moveLeft()
				end
			else
				self:moveLeft()
			end
		elseif name=="right" then
			if Input.isActive("wordModifier", "textInput") then
				while self:getRightOfCursor():match("^%W") do
					self:moveRight()
				end
				while self:getRightOfCursor():match("^%w") do
					self:moveRight()
				end
			else
				self:moveRight()
			end
		elseif name=="removeLeft" then
			if self.selection then
				self.selection = nil
			else
				if Input.isActive("wordModifier", "textInput") then
					while self:getLeftOfCursor():match("%W$") do
						self.left = self.left:sub(1,-2)
					end
					while self:getLeftOfCursor():match("%w$") do
						self.left = self.left:sub(1,-2)
					end
				else
					self.left = self.left:sub(1,-2)
				end
			end
			self:changed()
		elseif name=="removeRight" then
			if self.selection then
				self.selection = nil
			else
				if Input.isActive("wordModifier", "textInput") then
					while self:getRightOfCursor():match("^%W") do
						self.right = self.right:sub(2)
					end
					while self:getRightOfCursor():match("^%w") do
						self.right = self.right:sub(2)
					end
				else
					self.right = self.right:sub(2)
				end
			end
			self:changed()
		elseif name=="gotoFirst" then
			while self:getLeftOfCursor()~="" do
				self:moveLeft()
			end
		elseif name=="gotoLast" then
			while self:getRightOfCursor()~="" do
				self:moveRight()
			end
		elseif name=="defocusDetection" then
			-- this one isn't cursor bound, so will trigger when clicked outside the textbox
			-- it also trigger with a mouse click when we want to focus, so only run when we didn't just focus
			if self.timer~=0 then
				self:defocus()
			end
		end
		if not name:match("Modifier") then
			self.timer = 0
		end
		
		-- self:updateDisplayText() -- selection changes can break the displayed text
	end
end

function UI:onMouseMoved(x,y,_dx,_dy)
	if x > 0 and x < self.width and y > 0 and y < self.height then
		love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"))
		
		if self.focussed and Input.isActive("click","main") then
			local pos = self:roundToChar(self.textDisplay:getMouseX())
			while pos > self:getCurrentCaretPos() do
				self:moveRight(true)
			end
			while pos < self:getCurrentCaretPos() do
				self:moveLeft(true)
			end
		end
	else
		love.mouse.setCursor()
	end
end

return UI