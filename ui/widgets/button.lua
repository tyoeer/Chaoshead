local TEXT = require("ui.widgets.text")

local UI = Class("ButtonUI",require("ui.base.container"))

function UI:initialize(contents,onClick,style,triggerOnActivate)
	UI.super.initialize(self)
	
	if type(contents)=="table" then
		self.contents = contents
		self.managingContents = false
	else
		self.contents = TEXT:new(contents)
		self.managingContents = true
	end
	self:addChild(self.contents)
	
	self:setStyle(style)
	
	self.onClick = onClick
	self.triggerOnActivate = (triggerOnActivate==nil) and false or triggerOnActivate
	
	self.contents:move(style.padding,style.padding)
end

function UI:setStyle(style)
	if not style.padding then
		error("Padding not specified!",2)
	end
	if style.border==nil then
		error("Border not specified!",2)
	end
	if style.normal then
		if not style.normal.backgroundColor then
			error("Normal background color not specified",2)
		end
		if style.border and not style.normal.borderColor then
			error("Normal border color not specified",2)
		end
	else
		error("Normal colors not specified",2)
	end
	if style.hover then
		if not style.hover.backgroundColor then
			error("Hover background color not specified",2)
		end
		if style.border and not style.hover.borderColor then
			error("Hover border color not specified",2)
		end
	else
		error("Hover colors not specified",2)
	end
	if self.managingContents then
		if style.textStyle then
			self.contents:setStyle(style.textStyle)
		else
			error("Text style not specified!",2)
		end
	end
	self.style = style
end

function UI:getMinimumHeight(width)
	--local w, text = self.font:getWrap(self.text, width-2*self.padding)
	--local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return self.contents:getMinimumHeight(width-2*self.style.padding) + 2*self.style.padding
end

function UI:resized(width,height)
	self.contents:resize(width-2*self.style.padding, height - 2*self.style.padding)
	self.contents:move(style.padding,style.padding)
end

function UI:preDraw()
	local x,y = self:getMousePos()
	local subStyle
	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		subStyle = self.style.hover
	else
		subStyle = self.style.normal
	end
	if self.managingContents and self.contents.style ~= substyle then
		self.contents:setStyle(subStyle.textStyle)
	end
	
	love.graphics.setColor(subStyle.backgroundColors)
	love.graphics.rectangle("fill",0,0,self.width,self.height)
	if self.style.border then
		love.graphics.setColor(subStyle.borderColor)
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
