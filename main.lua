--localhost:8000

function love.load(arg)
	--load stuff
	lovebird = require("libs.lovebird")
	lovebird.update()
	require("utils.utils")
	
	--temp
	require("temp")
	
	function Class(a,b)
		if a==nil then
			return require("libs.middleclass")("Unnamed")
		elseif type(a)=="table" then
			return require("libs.middleclass")("Unnamed",a)
		elseif type(a)=="string" then
			return require("libs.middleclass")(a,b)
		end
	end
	
	--constants
	TILE_SIZE = 71
	
	--globals
	levelFile = require("levelhead.lhs"):new()
	levelFile:readAll()
	level = levelFile:parseAll()
	
	--love2d state
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	
	--build ui
	ui = require("ui.structure.tabs"):new(love.graphics.getWidth(),love.graphics.getHeight())
	
	local hexInspector = require("ui.structure.movableCamera"):new(
		-1,-1,
		require("ui.hexInspector"):new(-1,-1)
	)
	ui:addChild(hexInspector)
	
	local levelEditor = require("ui.levelEditor"):new(-1,-1)
	ui:addChild(levelEditor)
	
	local worldViewer = require("ui.structure.movableCamera"):new(
		-1,-1,
		require("ui.worldViewer"):new(-1,-1)
	)
	ui:addChild(worldViewer)
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
	ui:keypressed(key, scancode, isrepeat)
end
function love.textinput(text)
	ui:textinput(text)
end

function love.mousepressed(x, y, button, isTouch)
	ui:mousepressed(x,y, button, isTouch)
end
function love.mousereleased(x, y, button, isTouch)
	ui:mousereleased(x,y, button, isTouch)
end
function love.mousemoved(x, y, dx, dy)
	ui:mousemoved(x, y, dx, dy)
end
function love.wheelmoved(x, y)
	ui:wheelmoved(x,y)
end
