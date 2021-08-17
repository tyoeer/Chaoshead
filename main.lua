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
	--ui = require("ui.chaoshead"):new(love.graphics.getWidth(), love.graphics.getHeight())
	local list = require("ui.layout.list"):new(5,15)
	list:addTextEntry("Hello, right!")
	list:addTextEntry("Helloer, right!")
	list:addButtonEntry("Addissimo",function() list:addTextEntry(os.time()) end,5)
	list:addTextEntry("Helloest, right!")
	local r = require("ui.layout.padding"):new(list,5)
	r = require("ui.layout.scrollbar"):new(r)
	local l = require("ui.widgets.button"):new("Hello, left!",function()
		for i=0,20,1 do
			list:addTextEntry(string.rep("Left! ",i),math.floor(i/5))
		end
	end,5,true)
	ui = require("ui.layout.tabs"):new(30)
	ui:addTab(require("ui.layout.horDivide"):new(l,r))
	local c = require("ui.widgets.text"):new("Hello!\n\nHello!\n\nHello!\n\nGetting kind of repetitve\n\nisn't it?",0,"center","bottom")
	c.title = "Hello!"
	ui:addTab(c)
	local d = require("ui.widgets.text"):new("Hello!\n\nHello!\n\nHello!\n\nGetting kind of repetitve\n\nisn't it?",0,"center","center")
	d.title = "Helloer!"
	ui:addTab(d)
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
