--localhost:8000

function love.load(arg)
	--define globals
	lovebird = require("libs.lovebird")
	lovebird.update()
	require("utils.utils")
	suit = require("libs.suit")
	
	function Class(a,b)
		if a==nil then
			return require("libs.middleclass")("Unnamed")
		elseif type(a)=="table" then
			return require("libs.middleclass")("Unnamed",a)
		elseif type(a)=="string" then
			return require("libs.middleclass")(a,b)
		end
	end
	
	TILE_SIZE = 71
	
	--love2d state
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(1)
	love.graphics.setLineStyle("rough")
	--build ui
	ui = require("ui.tabs"):new(love.graphics.getWidth(),love.graphics.getHeight())
	local worldViewer = require("ui.movableCamera"):new(
		-1,-1,
		require("ui.worldViewer"):new(-1,-1,nil)
	)
	ui:addChild(worldViewer)
	local hexExplorer = require("ui.movableCamera"):new(
		-1,-1,
		require("ui.levelBytes"):new(-1,-1,nil)
	)
	ui:addChild(hexExplorer)
end

function love.update(dt)
	lovebird.update(dt)
	ui:update(dt)
end

function love.draw()
	ui:draw()
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
