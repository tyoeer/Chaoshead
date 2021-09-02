function love.load(arg)
	--load stuff
	require("utils.utils")
	
	local TU = require("libs.tyoeerUtils")(require("libs.middleclass"))
	Class = TU("oop")
	
	--constants
	TILE_SIZE = 71
	
	--globals
	settings = require("settings")
	input = TU("input")
	
	--love2d state
	love.graphics.setFont(love.graphics.newFont("font/anonymous-pro.regular.ttf",18))
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	--maximize window
	love.window.maximize()
	
	--build ui
	ui = require("ui.chaoshead"):new()
	ui = require("ui.base.root"):new(ui)
	ui:resize(love.graphics.getWidth(), love.graphics.getHeight())
	--bind ui and input
	input.parseActions(settings.bindings)
	input.inputActivated = function(...)
		ui:inputActivated(...)
	end
	input.inputDeactivated = function(...)
		ui:inputDeactivated(...)
	end
end

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

function love.keypressed(key, scancode, isrepeat)
	input.keypressed(key, scancode, isrepeat)
	--ui:keypressed(key, scancode, isrepeat)
end
function love.textinput(text)
	ui:textInput(text)
end
function love.keyreleased(key, scancode)
	input.keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, isTouch, presses)
	input.mousepressed(x,y, button, isTouch, presses)
	--ui:mousepressed(x,y, button, isTouch)
end
function love.mousereleased(x, y, button, isTouch, presses)
	input.mousereleased(x,y, button, isTouch, presses)
	--ui:mousereleased(x,y, button, isTouch)
end
function love.mousemoved(x, y, dx, dy)
	ui:mouseMoved(x, y, dx, dy)
end
function love.wheelmoved(dx, dy)
	ui:wheelMoved(dx,dy)
end
