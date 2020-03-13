local BaseUI = Class()

function BaseUI:initialize(w,h)
	self:resize(w,h)
end

function BaseUI:resize(w,h)
	self.width = w
	self.height = h
end

function BaseUI:update(dt)
	
end

function BaseUI:draw()
	
end

function BaseUI:keypressed(key, scancode, isrepeat)
	
end

function BaseUI:mousemoved(x, y, dx, dy)
	
end

function BaseUI:wheelmoved(x, y)
	
end

return BaseUI
