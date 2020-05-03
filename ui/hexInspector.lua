local BaseUI = require("ui.base")
local LHS = require("levelhead.lhs")

--LevelBytesUI
local UI = Class(BaseUI)

local function bytesToHex(bytes)
	local out = love.data.encode("string","hex",bytes)
	out = out:upper()
	out = out:gsub("(..)","%1 ")
	--remove the last space
	return out:sub(1,-2)
end

function UI:initialize(level)
	UI.super.initialize(self)
	self.title = "Hex Inspector"
	
	self:reload()
end

function UI:reload()
	local l = levelFile
	require("utils.levelUtils").reload()
	--l:readAll()
	
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

function UI:focus(focus)
	if focus then
		self:reload()
	end
end

local indentSize = settings.hexInspector.indentSize
local rowHeight = settings.hexInspector.rowHeight
local xPadding = settings.hexInspector.xPadding
local yPadding = settings.hexInspector.yPadding
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
local function sectionRows(section, label)
	textRow(label..": ".. levelFile.rawContentEntries[section].nEntries)
	for _,v in ipairs(levelFile.rawContentEntries[section].entries) do
		local hex = bytesToHex(levelFile.raw:sub(v.startOffset,v.endOffset))
		textRow(hex,2)
	end
end
local function propertyRows(section, label)
	textRow(label..": ".. levelFile.rawContentEntries[section].nEntries)
	for _,v in ipairs(levelFile.rawContentEntries[section].entries) do
		local hex = bytesToHex(levelFile.raw:sub(v.startOffset,v.endOffset))
		textRow(hex,2)
		for _,w in ipairs(v.entries) do
			textRow("-> "..w.value,2)
			for _,u in ipairs(w.entries) do
				textRow("("..(u.x+1)..","..(u.y+1)..")",3)
			end
		end
	end
end
function UI:draw()
	resetRows(self)
	local c = levelFile.rawContentEntries
	love.graphics.setColor(1,1,1)
	textRow("Headers:",-1)
		row("all")
		row("prefix")
		row("bgm")
		row("powerups","Player Share Powerups")
		row("weather")
		row("respawn","MP respawn style")
		row("camera","Camera hor. boundary")
		textRow("Title: "..#(levelFile.rawHeaders.title))
			for _,v in ipairs(levelFile.rawHeaders.title) do
				textRow(v,1)
			end
		row("zone")
		row("lWidth","Level width")
			textRow("-> "..levelFile.rawHeaders.width,1)
		row("lHeight","Level height")
			textRow("-> "..levelFile.rawHeaders.height,1)
		row("unknown")
	textRow("Content:",-1)
		sectionRows("singleForeground","Single foreground objects")
		sectionRows("foregroundRows","Foreground rows")
		sectionRows("foregroundColumns","Foreground columns")
		propertyRows("objectProperties","Object Properties")
		propertyRows("pathProperties","Path Properties")
		textRow("Repeated Property Sets:")
			textRow(bytesToHex(levelFile.raw:sub(c.pathProperties.endOffset+1)),1)
			textRow(bytesToHex(levelFile.raw:sub(c.pathProperties.endOffset+2)),1)
end

function UI:keypressed(key, scancode, isrepeat)
	if key=="r" or key=="space" then
		self:reload()
	end
end

return UI
