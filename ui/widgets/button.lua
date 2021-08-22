local TEXT = require("ui.widgets.text")

local UI = Class("ButtonUI",require("ui.base.container"))

function UI:initialize(contents,onClick,padding,triggerOnActivate)
	UI.super.initialize(self)
	if type(contents)=="table" then
		self.contents = contents
	else
		self.contents = TEXT:new(contents)
	end
	self:addChild(self.contents)
	
	self.onClick = onClick
	self.padding = padding
	self.contents:move(padding,padding)
	self.triggerOnActivate = (triggerOnActivate==nil) and false or triggerOnActivate
	self.drawBorder = true
end

function UI:setBorder(drawBorder)
	self.drawBorder = drawBorder
end

function UI:getMinimumHeight(width)
	--local w, text = self.font:getWrap(self.text, width-2*self.padding)
	--local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return self.contents:getMinimumHeight(width-2*self.padding) + 2*self.padding
end

function UI:resized(width,height)
	self.contents:resize(width-2*self.padding, height - 2*self.padding)
end

function UI:preDraw()
	local x,y = self:getMousePos()
	local col
	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		col = settings.col.list.button.hover
	else
		col = settings.col.list.button.other
	end
	love.graphics.setColor(col.bg)
	love.graphics.rectangle("fill",0,0,self.width,self.height)
	if self.drawBorder then
		love.graphics.setColor(col.outline)
		love.graphics.rectangle("line",0.5,0.5,self.width-1,self.height-1)
	end
end

function UI:onInputActivated(name,group,isCursorBound)
	if self.triggerOnActivate and name=="click" and group=="main" then
		self.onClick()
	end
end

function UI:onInputDeactivated(name,group,isCursorBound)
	if not self.triggerOnActivate and name=="click" and group=="main" then
		self.onClick()
	end
end

return UI
