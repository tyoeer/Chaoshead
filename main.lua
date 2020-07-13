--localhost:8000

function love.load(arg)
	--load stuff
	lovebird = require("libs.lovebird")
	lovebird.update()
	require("utils.utils")
	
	function Class(a,b)
		if a==nil then
			return require("libs.middleclass")("Unnamed")
		elseif type(a)=="table" then
			return require("libs.middleclass")("Unnamed",a)
		elseif type(a)=="string" then
			return require("libs.middleclass")(a,b)
		end
	end
	
	--temp
	require("temp")
	
	--constants
	TILE_SIZE = 71
	
	--globals
	settings = require("settings")
	input = require("input.system")
	
	--love2d state
	love.graphics.setFont(love.graphics.newFont("font/cnr.otf",16))
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	
	--build ui
	ui = require("ui.chaoshead"):new()
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


function love.update(dt)
	lovebird.update(dt)
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
function love.resize(w, h)
	ui:resize(w,h)
end

function love.keypressed(key, scancode, isrepeat)
	input.keypressed(key, scancode, isrepeat)
	--ui:keypressed(key, scancode, isrepeat)
end
function love.textinput(text)
	ui:textinput(text)
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
	ui:mousemoved(x, y, dx, dy)
end
function love.wheelmoved(x, y)
	ui:wheelmoved(x,y)
end
