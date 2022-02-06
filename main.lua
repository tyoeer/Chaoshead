function love.load(arg)
	--load stuff
	require("utils.utils")
	
	local TU = require("libs.tyoeerUtils")(require("libs.middleclass"))
	Class = TU("oop")
	
	--constants
	TILE_SIZE = 71
	
	--globals
	DISABLE_EDITOR_LIMITS = false
	Settings = require("settings")
	Storage = Settings.storage
	Input = TU("input")
	
	--love2d state
	love.graphics.setFont(love.graphics.newFont("font/iosevka-aile-regular.ttf",16))
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	--maximize window
	love.window.maximize()
	
	--build ui
	MainUI = require("ui.chaoshead"):new()
	UiRoot = require("ui.base.root"):new(MainUI)
	UiRoot:hookIntoLove()
	UiRoot:resize(love.graphics.getWidth(), love.graphics.getHeight())
	
	--bind ui and input
	Input.parseActions(Settings.bindings)
	Input.inputActivated = function(...)
		MainUI:inputActivated(...)
	end
	Input.inputDeactivated = function(...)
		MainUI:inputDeactivated(...)
	end
end

function love.keypressed(key, scancode, isrepeat)
	Input.keypressed(key, scancode, isrepeat)
	--ui:keypressed(key, scancode, isrepeat)
end
function love.keyreleased(key, scancode)
	Input.keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, isTouch, presses)
	Input.mousepressed(x,y, button, isTouch, presses)
	--ui:mousepressed(x,y, button, isTouch)
end
function love.mousereleased(x, y, button, isTouch, presses)
	Input.mousereleased(x,y, button, isTouch, presses)
	--ui:mousereleased(x,y, button, isTouch)
end
