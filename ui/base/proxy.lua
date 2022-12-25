---@class ProxyUI : ContainerUI
---@field super ContainerUI
---@field new fun(self: Object, child: BaseNodeUI): ProxyUI
local UI = Class("ProxyUI",require("ui.base.container"))

-- child can be temporary nil, but should not be when actually handling events

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

function UI:getMinimumHeight(width)
	return self.child:getMinimumHeight(width)
end

return UI
