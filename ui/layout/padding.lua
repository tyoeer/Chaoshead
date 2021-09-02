local UI = Class("PaddingUI",require("ui.base.proxy"))

function UI:initialize(child,padding)
	UI.super.initialize(self,child)
	if not padding then
		error("Padding not specified!")
	end
	self.paddingLeft = padding
	self.paddingRight = padding
	self.paddingUp = padding
	self.paddingDown = padding
	self.child:move(self.paddingLeft,self.paddingUp)
end

function UI:getMinimumHeight(width)
	width = width or self.width
	return self.child:getMinimumHeight(width - self.paddingLeft - self.paddingRight) + self.paddingUp + self.paddingDown
end

function UI:resized(w,h)
	self.child:resize(w - self.paddingLeft - self.paddingRight, h - self.paddingUp - self.paddingDown)
end


return UI
