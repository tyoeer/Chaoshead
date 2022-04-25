local TEXT = require("ui.widgets.text")

local UI = Class("ButtonUI",require("ui.base.container"))

function UI:initialize(contents,onClick,style,triggerOnActivate)
	UI.super.initialize(self)
	
	self:setStyle(style)
	
	if type(contents)=="table" then
		self.contents = contents
		self.managingContents = false
	else
		self.contents = TEXT:new(contents,0,style.normal.textStyle)
		self.managingContents = true
	end
	self:addChild(self.contents)
	
	
	
	self.onClick = onClick
	self.triggerOnActivate = (triggerOnActivate==nil) and false or triggerOnActivate
	
	self.contents:move(style.padding,style.padding)
end

function UI:setStyle(style)
	if not style then
		error("No style specified!",2)
	end
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
		if self.managingContents and not style.normal.textStyle then
			error("Normal text style not specified!",2)
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
		if self.managingContents and not style.hover.textStyle then
			error("Hover text style not specified!",2)
		end
	else
		error("Hover colors not specified",2)
	end
	--self.contents can be nil, setStyle gets called (to verify style integrity) before contents get created
	if self.managingContents and self.contents then
		self.contents:setStyle(style.normal.textStyle)
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
	self.contents:move(self.style.padding,self.style.padding)
end

function UI:preDraw()
	local x,y = self:getMousePos()
	local subStyle
	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		subStyle = self.style.hover
	else
		subStyle = self.style.normal
	end
	if self.managingContents and self.contents.style ~= subStyle then
		self.contents:setStyle(subStyle.textStyle)
	end
	
	love.graphics.setColor(subStyle.backgroundColor)
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
