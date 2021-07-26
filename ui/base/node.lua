local UI = Class("UINode")

function UI:initialize()
	-- it's parent
	--self.parent
	--following values are stubbed so UI nodes don't have to be worried about whether they're moved/resized yet
	-- position relative to it's parent:
	self.x = 0
	self.y = 0
	-- display size
	-- stubbing using (-1,-1) leads to bugs
	-- (scrollbar defaulted to the bottom because the negative value got it to think it had scrolled to far)
	self.width = math.huge
	self.height = math.huge
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
function UI:wheelMoved(dx,dy) end

return UI
