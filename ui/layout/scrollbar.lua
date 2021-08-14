local Text = require("ui.widgets.text")
local Button = require("ui.widgets.button")

local UI = Class(require("ui.base.container"))

function UI:initialize(contents)
	UI.super.initialize(self)
	
	self.scrollAreaHeight = math.huge
	self.contentOffset = 0
	self.scrollButtonOffset = 0
	self.buttonX = self.width - settings.dim.misc.scrollbar.width
	
	self.contents = contents
	self:addChild(contents)
	
	self.upButton = Button:new(Text:new("Λ",0,"center","center"), function()
		self:scrollToOffset(self.contentOffset - settings.misc.scrollbar.buttonScrollSpeed)
	end, 0)
	self:addChild(self.upButton)
	self.upButton:resize(settings.dim.misc.scrollbar.width, settings.dim.misc.scrollbar.buttonHeight)
	
	self.downButton = Button:new(Text:new("V",0,"center","center"), function()
		self:scrollToOffset(self.contentOffset + settings.misc.scrollbar.buttonScrollSpeed)
	end, 0)
	self:addChild(self.downButton)
	self.downButton:resize(settings.dim.misc.scrollbar.width, settings.dim.misc.scrollbar.buttonHeight)
	
	self.scrollButton = Button:new(Text:new("=",0,"center","center"), function()
		self.dragging = true
	end, 5,true)
	self:addChild(self.scrollButton)
	self:updateScrollButton()
	
end

function UI:updateScrollButton()
	--[[
	the division calculates how much bigger the display size is than the child
	which gets clamped(math.min) down to 1 to prevent the scroll button from becoming bigger than it's available area
	which then gets multiplied by the area available to the scroll button to get its height
	]]
	local height = math.min(1, self.height / self.contents:getMinimumHeight() ) * self.scrollAreaHeight
	self.scrollButton:resize(settings.dim.misc.scrollbar.width, math.floor(0.5+height) )
	--math.min to prevent scrolling beyond the height of the contents (it could have been reduced due to an update in them)
	self:scrollToOffset(math.min(self.contentOffset,self.contents:getMinimumHeight()))
end

function UI:scroll(scrollButtonOffset)
	if self.scrollButton.height == self.scrollAreaHeight then
		self.contents:move(0,0)
		self.scrollButton:move(self.buttonX, settings.dim.misc.scrollbar.buttonHeight)
	else
		self.scrollButtonOffset = scrollButtonOffset
		if self.scrollButtonOffset < 0 then
			self.scrollButtonOffset = 0
		elseif self.scrollButtonOffset > self.scrollAreaHeight-self.scrollButton.height then
			self.scrollButtonOffset = self.scrollAreaHeight-self.scrollButton.height
		end
		self.scrollButton:move(self.buttonX, settings.dim.misc.scrollbar.buttonHeight + self.scrollButtonOffset)
		--formula is the inverse of the one in UI:scrollToOffset, and works effectively the same
		self.contentOffset = math.floor(
			self.scrollButtonOffset
			/ (self.scrollAreaHeight-self.scrollButton.height)
			* (self.contents:getMinimumHeight()-self.height)
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
		/ (self.contents:getMinimumHeight()-self.height)
		* (self.scrollAreaHeight-self.scrollButton.height)
	))
end

-- events

function UI:childMinimumHeightChanged(child)
	local cw = self.width - settings.dim.misc.scrollbar.width
	local ch = child:getMinimumHeight(cw)
	self.contents:resize(cw, math.max(ch,self.height))
	self:updateScrollButton()
end

function UI:resized(w,h)
	self.buttonX = self.width - settings.dim.misc.scrollbar.width
	self.upButton:move(self.buttonX, 0)
	self.downButton:move(self.buttonX, h - settings.dim.misc.scrollbar.buttonHeight)
	self.scrollAreaHeight = h - 2* settings.dim.misc.scrollbar.buttonHeight
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
		self:scroll(self.scrollButtonOffset + dy)
	end
end

function UI:onWheelMoved(dx,dy)
	self:scrollToOffset(self.contentOffset + -dy*settings.misc.scrollbar.mouseWheelScrollSpeed)
end

return UI
