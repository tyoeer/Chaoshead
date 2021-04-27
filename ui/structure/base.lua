local BaseUI = Class("BaseUI")

function BaseUI:initialize()
	self.title = "Unnamed"
	--using (-1,-1) leads to bugs (scrollbar defaulted to the bottom because the negative value got it to think it had scrolled to far)
	self:resize(math.huge,math.huge)
end


function BaseUI:getMouseX()
	if self.parent then
		return self.parent:getPropagatedMouseX(self)
	else
		return love.mouse.getX()
	end
end
function BaseUI:getMouseY()
	if self.parent then
		return self.parent:getPropagatedMouseY(self)
	else
		return love.mouse.getY()
	end
end

function BaseUI:getPropagatedMouseX(child)
	return self:getMouseX()
end
function BaseUI:getPropagatedMouseY(child)
	return self:getMouseY()
end

function BaseUI:getMousePos()
	return self:getMouseX(), self:getMouseY()
end


function BaseUI:update(dt) end

function BaseUI:draw() end

function BaseUI:focus(focus) end
function BaseUI:visible(visible) end
function BaseUI:resize(w,h)
	self.width = w
	self.height = h
end

function BaseUI:inputActivated(name,group,isCursorBound) end
function BaseUI:inputDeactivated(name,group,isCursorBound) end

function BaseUI:textInput(text) end

function BaseUI:mouseMoved(x, y, dx, dy) end
function BaseUI:wheelMoved(x, y) end

return BaseUI
