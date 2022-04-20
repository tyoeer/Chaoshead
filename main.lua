function love.load(arg)
	--load stuff
	require("utils.utils")
	
	local TU = require("libs.tyoeerUtils")(require("libs.middleclass"))
	Class = TU("oop")
	
	--constants
	TILE_SIZE = 71
	
	--globals
	VERSION = love.filesystem.read("version.txt")
	if not VERSION then
		VERSION = "DEV"
	end
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
	
	--show reset settings dialog
	require("ui.updateSettings")
	
	--bind ui and input
	Input.parseActions(Settings.bindings)
	Input.inputActivated = function(...)
		UiRoot:inputActivated(...)
	end
	Input.inputDeactivated = function(...)
		UiRoot:inputDeactivated(...)
	end
end

function love.keypressed(key, scancode, isrepeat)
	Input.keypressed(key, scancode, isrepeat)
end
function love.keyreleased(key, scancode)
	Input.keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, isTouch, presses)
	Input.mousepressed(x,y, button, isTouch, presses)
end
function love.mousereleased(x, y, button, isTouch, presses)
	Input.mousereleased(x,y, button, isTouch, presses)
end
