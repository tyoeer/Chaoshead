local UI = Class(require("ui.base.container"))

function UI:initialize(child)
	UI.super.initialize(self)
	self.child = child
	self:addChild(child)
end

function UI:getMouseX()
	return love.mouse.getX()
end
function UI:getMouseY()
	return love.mouse.getY()
end

function UI:resized(w,h)
	self.child:resize(w,h)
end

return UI
