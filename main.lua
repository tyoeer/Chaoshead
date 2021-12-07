function love.load(arg)
	--load stuff
	require("utils.utils")
	
	local TU = require("libs.tyoeerUtils")(require("libs.middleclass"))
	Class = TU("oop")
	
	--constants
	TILE_SIZE = 71
	
	--globals
	settings = require("settings")
	storage = settings.storage
	input = TU("input")
	
	--love2d state
	love.graphics.setFont(love.graphics.newFont("font/iosevka-aile-regular.ttf",18))
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	--maximize window
	love.window.maximize()
	
	--build ui
	ui = require("ui.chaoshead"):new()
	uiRoot = require("ui.base.root"):new(ui)
	uiRoot:hookIntoLove()
	uiRoot:resize(love.graphics.getWidth(), love.graphics.getHeight())
	
	--bind ui and input
	input.parseActions(settings.bindings)
	input.inputActivated = function(...)
		ui:inputActivated(...)
	end
	input.inputDeactivated = function(...)
		ui:inputDeactivated(...)
	end
end

function love.keypressed(key, scancode, isrepeat)
	input.keypressed(key, scancode, isrepeat)
	--ui:keypressed(key, scancode, isrepeat)
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
