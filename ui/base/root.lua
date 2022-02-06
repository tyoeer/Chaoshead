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


function UI:hookIntoLove()
	function love.resize(w, h)
		self:resize(w,h)
	end
	
	function love.update(dt)
		self:update(dt)
	end
	function love.draw()
		self:draw()
	end
	
	function love.focus(focus)
		self:focus(focus)
	end
	function love.visible(visible)
		self:visible(visible)
	end
	
	function love.textinput(text)
		self:textInput(text)
	end
	
	function love.mousemoved(x, y, dx, dy)
		self:mouseMoved(x, y, dx, dy)
	end
	function love.wheelmoved(dx, dy)
		self:wheelMoved(dx,dy)
	end
end


return UI
