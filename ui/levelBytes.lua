local BaseUI = require("ui.base")
local LHS = require("levelhead.lhs")

--LevelBytesUI
local LBUI = Class(BaseUI)
--in case it ever changes, and this feels better
local Parent = LBUI.super

local function bytesToHex(bytes)
	local out = love.data.encode("string","hex",bytes)
	out = out:upper()
	out = out:gsub("(..)","%1 ")
	--remove the last space
	return out:sub(1,-1)
end

function LBUI:initialize(w,h,level)
	Parent.initialize(self,w,h)
	self.title = "Hex Inspector"
	
	if type(level)=="table" then
		self:setLevel(level)
	elseif type(level)=="string" then
		self:loadLevel(level)
	elseif level == nil then
		self:loadLevel()
	else
		error("Invalid level type: "..type(level).." "..tostring(level))
	end
	
	self:reload()
end

function LBUI:loadLevel(level)
	self.level = LHS:new(level)
end

function LBUI:setLevel(level)
	self.level = level
end

function LBUI:reload()
	local l = self.level
	l:readAll()
	--table.print(l.rawContentEntries)
	self.all = bytesToHex(l.raw)
	self.prefix = bytesToHex(l:getBytes(1,9))
	self.bgm = bytesToHex(l:getBytes(10,5))
	self.powerups = bytesToHex(l:getBytes(16,2))
	self.weather = bytesToHex(l:getBytes(18,4))
	self.respawn = bytesToHex(l:getBytes(22,2))
	self.camera = bytesToHex(l:getBytes(24,1))
	self.zone = bytesToHex(l:getBytes(l.titleEndOffset+1,1))
	self.width = bytesToHex(l:getBytes(l.titleEndOffset+2,1))
	self.height = bytesToHex(l:getBytes(l.titleEndOffset+3,1))
	self.unknown = bytesToHex(l:getBytes(l.titleEndOffset+4,4))
end

function LBUI:draw()
	love.graphics.print(self.all, 10,10)
	love.graphics.print("Prefix: "..self.prefix, 10,30)
	love.graphics.print("BGM: "..self.bgm, 10,50)
	love.graphics.print("Player Share Powerups: "..self.powerups, 10,70)
	love.graphics.print("Weather: "..self.weather, 10,90)
	love.graphics.print("MP respawn style: "..self.respawn, 10,110)
	love.graphics.print("Camera hor. boundary: "..self.camera, 10,130)
	love.graphics.print("Title: "..#(self.level.rawHeaders.title), 10,150)
	local offset = 150
	for i,v in ipairs(self.level.rawHeaders.title) do
		offset = offset + 20
		love.graphics.print(v, 30,offset)
	end
	love.graphics.print("Zone: "..self.zone, 10,offset+020)
	love.graphics.print("Width: "..self.level.rawHeaders.width.." #"..self.width, 10,offset+040)
	love.graphics.print("Height: "..self.level.rawHeaders.height.." #"..self.height, 10,offset+060)
	love.graphics.print("Unknown: "..self.unknown, 10,offset+080)
end

function LBUI:keypressed(key, scancode, isrepeat)
	if key=="r" or key=="space" then
		self:loadLevel(self.level.fileName)
		self:reload()
	end
end

return LBUI
