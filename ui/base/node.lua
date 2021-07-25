local UI = Class("UINode")

function UI:intialize()
	-- it's parent
	--self.parent
	-- position relative to it's parent:
	--self.x
	--self.y
	-- display size
	--self.width
	--self.height
end

function UI:getMouseX()
	return self.parent:getMouseX() - self.x
end

function UI:getMouseY()
	return self.parent:getMouseY() - self.y
end

function UI:getMousePos()
	return self:getMouseX(), self:getMouseY()
end

--actions on this UI to be called by it's parent

function UI:resize(width,height)
	self.width = width
	self.height = height
end

function UI:move(x,y)
	self.x = x
	self.y = y
end

-- event stubs

function UI:update(dt) end
function UI:draw() end

function UI:focus(hasFocus) end
function UI:visible(isVisible) end
function UI:resized(width,height) end

function UI:inputActivated(name,group,isCursorBound) end
function UI:inputDeactivated(name,group,isCursorBound) end

function UI:textInput(text) end

function UI:mouseMoved(x,y, dx,dy) end
function UI:wheelMoved(x,y) end

return UI
