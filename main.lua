if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	require("lldebugger").start()
	-- Extra error because it otherwise misses them if they happen during love.load()
	function love.errorhandler(msg)
		error(msg,2)
	end
end

function love.load(args)
	--load stuff
	require("utils.utils")
	
	local TU = require("libs.tyoeerUtils")(require("libs.middleclass"))
	
	-- Boilerplate for types
	
	---@class Class
	---@field name string
	---@field super Class
	
	--has to be done as a table because generics can't be done on an abstract
	---@class Object : Class
	---@field class Class
	local c = {}
	---@generic T
	---@param self T
	---@return T
	function c:new(...) return self end
	
	--Globals unfortunately don't have types, so this doesn't actually work
	---@overload fun(): Class
	---@overlaod fun(parent: Class): Class
	---@overload fun(name: string, parent?: Class): Class
	Class = TU("oop")
	
	--constants
	TILE_SIZE = 71
	
	--globals
	Persistant = require("settings")
	Settings = Persistant.settings
	Storage = Persistant:get("data")
	Input = TU("input")
	--make sure which version of CH we're using is saved on disk
	require("utils.version")
	
	--love2d state
	love.graphics.setFont(love.graphics.newFont("resources/iosevka-aile-regular.ttf", Settings.theme.main.fontSize))
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	--maximize window
	if Storage.fullscreen then
		love.window.setFullscreen(true)
	else
		love.window.maximize()
	end
	
	--build ui
	MainUI = require("chaoshead.chaoshead"):new()
	UiRoot = require("ui.base.root"):new(MainUI)
	UiRoot:hookIntoLove()
	UiRoot:resize(love.graphics.getWidth(), love.graphics.getHeight())
	
	--bind ui and input
	Input.parseActions(Settings.bindings)
	Input.inputActivated = function(...)
		UiRoot:inputActivated(...)
	end
	Input.inputDeactivated = function(...)
		UiRoot:inputDeactivated(...)
	end
	
	--checks to run at startup
	require("chaoshead.startupChecks")
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