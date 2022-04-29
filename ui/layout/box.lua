local Padding = require("ui.layout.padding")
local Scrollbar = require("ui.tools.optionalScrollbar")

local UI = Class("BoxUI",require("ui.base.proxy"))

function UI:initialize(contents,style)
	if not style.padding then
		error("Padding not specified!",2)
	end
	if not style.backgroundColor then
		error("Background color not specified!",2)
	end
	if not style.borderColor then
		error("Border color not specified!",2)
	end
	if not style.minMargin then
		error("Minimum margin not specified!",2)
	end
	self.style = style
	self.padding = Padding:new(contents, style.padding)
	UI.super.initialize(self, Scrollbar:new(self.padding))
end

function UI:childMinimumHeightChanged()
	self:resized(self.width, self.height)
end

function UI:resized(width,height)
	local minH = self.padding:getMinimumHeight(width)
	local maxH = height - 2*self.style.minMargin
	height = math.min(minH,maxH)
	self.child:resize(width-2, height)
	self.child:move(1, math.floor((self.height-height)/2))
end

function UI:preDraw()
	love.graphics.setColor(self.style.backgroundColor)
	love.graphics.rectangle(
		"fill",
		self.child.x, self.child.y,
		self.child.width, self.child.height
	)
	love.graphics.setColor(self.style.borderColor)
	love.graphics.rectangle(
		"line",
		0.5, self.child.y-0.5,
		self.width-1, self.child.height+1
	)
end

return UI
