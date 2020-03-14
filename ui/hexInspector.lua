local BaseUI = require("ui.base")
local LHS = require("levelhead.lhs")

--LevelBytesUI
local UI = Class(BaseUI)
--in case it ever changes, and this feels better
local Super = UI.super

local function bytesToHex(bytes)
	local out = love.data.encode("string","hex",bytes)
	out = out:upper()
	out = out:gsub("(..)","%1 ")
	--remove the last space
	return out:sub(1,-1)
end

function UI:initialize(w,h,level)
	Super.initialize(self,w,h)
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

function UI:loadLevel(level)
	self.level = LHS:new(level)
end

function UI:setLevel(level)
	self.level = level
end

function UI:reload()
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
	self.lWidth = bytesToHex(l:getBytes(l.titleEndOffset+2,1))
	self.lHeight = bytesToHex(l:getBytes(l.titleEndOffset+3,1))
	self.unknown = bytesToHex(l:getBytes(l.titleEndOffset+4,4))
end

local indentSize = 20
local rowHeight = 20
local xPadding, yPadding = 10,10
local i = 0
local indent = 0
local this
local function resetRows(self)
	this = self
	i = 0
	indent = 1
end
local function textRow(text,extraIndent)
	extraIndent = extraIndent or 0
	love.graphics.print(text, (indent+extraIndent)*indentSize +xPadding, i*rowHeight +yPadding)
	i = i +1
end
local function row(display,label,extraIndent)
	local text = label or display:gsub("^.",string.upper)
	text = text .. ": "
	text = text .. this[display]
	textRow(text,extraIndent)
end

function UI:draw()
	resetRows(self)
	love.graphics.setColor(1,1,1)
	textRow("Headers:",-1)
		row("all")
		row("prefix")
		row("bgm")
		row("powerups","Player Share Powerups")
		row("weather")
		row("respawn","MP respawn style")
		row("camera","Camera hor. boundary")
		textRow("Title: "..#(self.level.rawHeaders.title))
			for _,v in ipairs(self.level.rawHeaders.title) do
				textRow(v,1)
			end
		row("zone")
		row("lWidth","Level width")
			textRow("-> "..self.level.rawHeaders.width,1)
		row("lHeight","Level height")
			textRow("-> "..self.level.rawHeaders.height,1)
		row("unknown")
	textRow("Content:",-1)
		textRow("Single Foreground Objects:")
		indent = 2
end

function UI:keypressed(key, scancode, isrepeat)
	if key=="r" or key=="space" then
		self:loadLevel(self.level.fileName)
		self:reload()
	end
end

return UI
