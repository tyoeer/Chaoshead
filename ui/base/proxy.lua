local UI = Class("ProxyUI",require("ui.base.container"))

function UI:initialize(child)
	UI.super.initialize(self)
	--self.child
	self:setChild(child)
end

function UI:setChild(child)
	if self.child then
		self:removeChild(self.child)
	end
	self.child = child
	self:addChild(child)
	child:resize(self.width, self.height)
	child:move(0,0)
end

function UI:resized(w,h)
	self.child:resize(w,h)
end

return UI
