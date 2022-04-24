--[[

Makes a scaled picture of the entire level and saves it to the Chaoshead userdata directory

]]--

local WorldEditor = require("levelEditor.worldEditor")

local ZOOM = 4
local TEXT = false

---@diagnostic disable-next-line: undefined-global
local bg = Settings.theme.levelEditor.colors.worldBackground

local canvas = love.graphics.newCanvas(level:getWidth()*TILE_SIZE/ZOOM, level:getHeight()*TILE_SIZE/ZOOM)

love.graphics.push("all")
love.graphics.setCanvas(canvas)
love.graphics.translate(-level.left*TILE_SIZE/ZOOM, -level.top*TILE_SIZE/ZOOM)
love.graphics.scale(1/ZOOM)
if ZOOM > 1 then
	love.graphics.setLineStyle("smooth")
else
	love.graphics.setLineStyle("rough")
end
local lgPrint
if not TEXT then
	--disable text to prevent distinguishing different elements.
	lgPrint = love.graphics.print
	love.graphics.print = function() end
end
	love.graphics.clear(bg)

-- self=nil beause we don't have a ui
WorldEditor.drawObjects(nil, level, level.left, level.top, level.right, level.bottom)

--reset drawState
love.graphics.pop()

if not TEXT then
	love.graphics.print = lgPrint
end
local name = level.settings:getTitle():gsub(" ","-").."__"..os.date("%y-%d-%m_%Hh%M.png")
name = name:gsub("[?<>\\/|:\"]","$")
canvas:newImageData():encode("png", name)