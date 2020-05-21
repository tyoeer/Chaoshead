local BaseUI = Class("BaseUI")

function BaseUI:initialize()
	self.title = "Unnamed"
	self:resize(-1,-1)
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

function BaseUI:inputActivated(name,group,isCursorBound)
	print(name,group,isCursorBound)
end
function BaseUI:inputDeactivated(name,group,isCursorBound)
	print(name,group,isCursorBound)
end

function BaseUI:textinput(text) end

function BaseUI:mousemoved(x, y, dx, dy) end
function BaseUI:wheelmoved(x, y) end

return BaseUI
