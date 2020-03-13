local BaseUI = Class()

function BaseUI:initialize(w,h)
	self.title = "Unnamed"
	self:resize(w,h)
end

function BaseUI:resize(w,h)
	self.width = w
	self.height = h
end

function BaseUI:getMouseX()
	return love.mouse.getX()
end

function BaseUI:getMouseY()
	return love.mouse.getY()
end

function BaseUI:getMousePos()
	return self:getMouseX(), self:getMouseY()
end

function BaseUI:update(dt)
	
end

function BaseUI:draw()
	
end


function BaseUI:keypressed(key, scancode, isrepeat)
	
end

function BaseUI:textinput(text)
	
end


function BaseUI:mousemoved(x, y, dx, dy)
	
end

function BaseUI:mousepressed(x, y, button, isTouch)
	
end

function BaseUI:mousereleased(x, y, button, isTouch)
	
end


function BaseUI:wheelmoved(x, y)
	
end

return BaseUI
