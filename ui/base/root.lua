local UI = Class("RootUI",require("ui.base.proxy"))

function UI:initialize(child)
	UI.super.initialize(self,child)
end

function UI:getMouseX()
	return love.mouse.getX()
end
function UI:getMouseY()
	return love.mouse.getY()
end

function UI:childMinimumHeightChanged(child)
	--we don't care
end

return UI
