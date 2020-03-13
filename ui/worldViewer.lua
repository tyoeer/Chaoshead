local BaseUI = require("ui.base")
local LHS = require("levelhead.lhs")

--LevelBytesUI
local UI = Class(BaseUI)
--in case it ever changes, and this feels better
local Parent = UI.super


function UI:initialize(w,h,level)
	Parent.initialize(self,w,h)
	
	if type(level)=="table" then
		self:setLevel(level)
	elseif type(level)=="string" then
		self:loadLevel(level)
	else
		error("Invalid level type: "..type(level).." "..tostring(level))
	end
	
	self:reload()
end

function UI:loadLevel(level)
	self.level = LHS:new(level)
end

function UI:setLevel(level)
	self.level = level
end

function UI:reload()
	local l = self.level
	l:readAll()
	self.world = l:parseAll()
end

function UI:draw()
	--bg
	love.graphics.setColor(0,0.5,1,1)
	love.graphics.rectangle(
		"fill",
		0, 0,
		self.world.width*TILE_SIZE, self.world.height*TILE_SIZE
	)
	for obj in self.world.allObjects:iterate() do
		obj:draw()
	end
end

function UI:keypressed(key, scancode, isrepeat)
	if key=="r" or key=="space" then
		self:loadLevel(self.level.fileName)
		self:reload()
	end
end

return UI
