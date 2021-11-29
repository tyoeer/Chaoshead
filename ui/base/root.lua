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
		ui:resize(w,h)
	end
	
	function love.update(dt)
		ui:update(dt)
	end
	function love.draw()
		ui:draw()
	end
	
	function love.focus(focus)
		ui:focus(focus)
	end
	function love.visible(visible)
		ui:visible(visible)
	end
	
	function love.textinput(text)
		ui:textInput(text)
	end
	
	function love.mousemoved(x, y, dx, dy)
		ui:mouseMoved(x, y, dx, dy)
	end
	function love.wheelmoved(dx, dy)
		ui:wheelMoved(dx,dy)
	end
end


return UI
