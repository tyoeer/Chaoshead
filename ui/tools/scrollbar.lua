local Button = require("ui.widgets.button")

local UI = Class("ScrollbarUI",require("ui.base.container"))

local theme = Settings.theme.scrollbar

function UI:initialize(contents)
	UI.super.initialize(self)
	
	self.scrollAreaHeight = math.huge
	self.contentOffset = 0
	self.scrollButtonOffset = 0
	self.buttonX = self.width - theme.width
	
	self.contents = contents
	self:addChild(contents)
	
	self.upButton = Button:new("Λ", function()
		self:scrollToOffset(self.contentOffset - self.height * Settings.misc.scrollbar.buttonScrollFactor)
	end, theme.buttonStyle)
	self:addChild(self.upButton)
	self.upButton:resize(theme.width, theme.buttonHeight)
	
	self.downButton = Button:new("V", function()
		self:scrollToOffset(self.contentOffset + self.height * Settings.misc.scrollbar.buttonScrollFactor)
	end, theme.buttonStyle)
	self:addChild(self.downButton)
	self.downButton:resize(theme.width, theme.buttonHeight)
	
	self.scrollButton = Button:new("=", function()
		self.dragging = true
	end, theme.buttonStyle, true)
	self:addChild(self.scrollButton)
	
	self:updateScrollButton()
end

function UI:updateScrollButton()
	--[[
	the division calculates how much bigger the display size is than the child
	which gets clamped(math.min) down to 1 to prevent the scroll button from becoming bigger than it's available area
	which then gets multiplied by the area available to the scroll button to get its height
	]]
	local displayContentsRatio = self.height / self.contents.height
	if displayContentsRatio~=displayContentsRatio then--test for NaN: content height could still be 0, in which case a NaN would scroll it all the way to the bottom
		displayContentsRatio = 1
	end
	local height = math.min(1, displayContentsRatio) * self.scrollAreaHeight
	self.scrollButton:resize(theme.width, math.floor(0.5+height) )
	--math.min to prevent scrolling beyond the height of the contents (it could have been reduced due to an update in them)
	self:scrollToOffset(math.min(self.contentOffset,self.contents.height))
end

function UI:scroll(scrollButtonOffset)
	if self.scrollButton.height == self.scrollAreaHeight then
		self.contents:move(0,0)
		self.scrollButton:move(self.buttonX, theme.buttonHeight)
	else
		self.scrollButtonOffset = scrollButtonOffset
		if self.scrollButtonOffset < 0 then
			self.scrollButtonOffset = 0
		elseif self.scrollButtonOffset > self.scrollAreaHeight-self.scrollButton.height then
			self.scrollButtonOffset = self.scrollAreaHeight-self.scrollButton.height
		end
		self.scrollButton:move(self.buttonX, theme.buttonHeight + self.scrollButtonOffset)
		--formula is the inverse of the one in UI:scrollToOffset, and works effectively the same
		self.contentOffset = math.floor(
			self.scrollButtonOffset
			/ (self.scrollAreaHeight-self.scrollButton.height)
			* (self.contents.height-self.height)
		)
		self.contents:move(0,-self.contentOffset)
	end
end
function UI:scrollToOffset(offset)
	--[[
	the formula is offset / height of the contents * the range the scrollbutton can scroll
	the first two parts are the factor (0.0-1.0) of how much down it is, the multiplication transforms it into
	the amount (of pixels) the scrollbutton has to move down
	]]
	self:scroll(math.floor(0.5+
		offset
		/ (self.contents.height-self.height)
		* (self.scrollAreaHeight-self.scrollButton.height)
	))
end

-- events

function UI:childMinimumHeightChanged(child)
	local cw = self.width - theme.width
	local ch = child:getMinimumHeight(cw)
	self.contents:resize(cw, math.max(ch,self.height))
	self:updateScrollButton()
	if ch <= self.height then
		--signal to the optional scrollbar that we might not be neccesary anymore
		self:minimumHeightChanged()
	end
end

function UI:resized(w,h)
	self.buttonX = self.width - theme.width
	self.upButton:move(self.buttonX, 0)
	self.downButton:move(self.buttonX, h - theme.buttonHeight)
	self.scrollAreaHeight = h - 2* theme.buttonHeight
	--update the scroll button through a sidetrack so code only has to be written once
	self:childMinimumHeightChanged(self.contents)
end

function UI:onInputDeactivated(name,group,isCursorBound)
	if group=="main" and name=="click" then
		self.dragging = false
	end
end

function UI:onMouseMoved(x,y,dx,dy)
	if self.dragging then
		-- it could have been released when hovering outside this node
		if Input.isActive("click","main") then
			self:scroll(self.scrollButtonOffset + dy)
		else
			self.dragging = false
		end
	end
end

function UI:onWheelMoved(dx,dy)
	self:scrollToOffset(self.contentOffset + -dy*Settings.misc.scrollbar.mouseWheelScrollSpeed)
end

return UI
