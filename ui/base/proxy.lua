local UI = Class("ProxyUI",require("ui.base.container"))

function UI:initialize(child)
	UI.super.initialize(self)
	--self.child
	if child then
		self:setChild(child)
	end
end

function UI:setChild(child)
	if self.child then
		self:unsetChild()
	end
	self.child = child
	self:addChild(child)
	child:resize(self.width, self.height)
	child:move(0,0)
end

function UI:unsetChild()
	self:removeChild(self.child)
	self.child = nil
end

function UI:resized(w,h)
	self.child:resize(w,h)
end

return UI
