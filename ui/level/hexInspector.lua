local BaseUI = require("ui.structure.base")

--LevelBytesUI
local UI = Class(BaseUI)

local function bytesToHex(bytes)
	local out = love.data.encode("string","hex",bytes)
	out = out:upper()
	out = out:gsub("(..)","%1 ")
	--remove the last space
	return out:sub(1,-2)
end

function UI:initialize(levelFile)
	self.levelFile = levelFile
	UI.super.initialize(self)
	self.title = "Hex Inspector"
	
	self:reload()
end

function UI:reload(l)
	if l then
		self.levelFile = l
	else
		l = self.levelFile
	end
	
	self.prefix = bytesToHex(l:getBytes(1,6))
	self.campaignMarker = bytesToHex(l:getBytes(7,1))
	self.nHeaders = bytesToHex(l:getBytes(8,1))
	self.bgm = bytesToHex(l:getBytes(9,2))
	self.mode = bytesToHex(l:getBytes(11,2))
	self.minPlayers = bytesToHex(l:getBytes(13,2))
	self.powerups = bytesToHex(l:getBytes(15,2))
	self.weather = bytesToHex(l:getBytes(17,2))
	self.language = bytesToHex(l:getBytes(19,2))
	self.respawn = bytesToHex(l:getBytes(21,2))
	self.camera = bytesToHex(l:getBytes(23,2))
	self.zone = bytesToHex(l:getBytes(l.titleEndOffset+1,1))
	self.lWidth = bytesToHex(l:getBytes(l.titleEndOffset+2,1))
	self.lHeight = bytesToHex(l:getBytes(l.titleEndOffset+3,1))
	self.unknown = bytesToHex(l:getBytes(l.titleEndOffset+4,4))
end

local indentSize = settings.dim.hexInspector.indentSize
local rowHeight = settings.dim.hexInspector.rowHeight
local xPadding = settings.dim.hexInspector.xPadding
local yPadding = settings.dim.hexInspector.yPadding
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
	textRow(label..": ".. this.levelFile.rawContentEntries[section].nEntries)
	for _,v in ipairs(this.levelFile.rawContentEntries[section].entries) do
		local hex = bytesToHex(this.levelFile.raw:sub(v.startOffset,v.endOffset))
		textRow(hex,2)
	end
end
local function propertyRows(section, label, isPath)
	textRow(label..": ".. this.levelFile.rawContentEntries[section].nEntries)
	for _,v in ipairs(this.levelFile.rawContentEntries[section].entries) do
		local hex = bytesToHex(this.levelFile.raw:sub(v.startOffset,v.endOffset))
		textRow(hex,2)
		for _,w in ipairs(v.entries) do
			textRow("-> "..w.value,2)
			for _,u in ipairs(w.entries) do
				if isPath then
					textRow("("..u..")",3)
				else
					textRow("("..(u.x+1)..","..(u.y+1)..")",3)
				end
			end
		end
	end
end
function UI:draw()
	resetRows(self)
	local c = self.levelFile.rawContentEntries
	love.graphics.setColor(1,1,1)
	textRow("Headers:",-1)
		row("prefix","Unknown: Prefix")
		row("campaignMarker","Unknown: CampaignMarker")
		row("nHeaders","Amount of headers")
		row("bgm")
		row("mode")
		row("minPlayers")
		row("powerups","Player share powerups")
		row("weather")
		row("language")
		row("respawn","MP respawn style")
		row("camera","Camera hor. boundary")
		textRow("Title: "..#(self.levelFile.rawHeaders.title))
			for _,v in ipairs(self.levelFile.rawHeaders.title) do
				textRow(v,1)
			end
		row("zone")
		row("lWidth","Level width")
			textRow("-> "..self.levelFile.rawHeaders.width,1)
		row("lHeight","Level height")
			textRow("-> "..self.levelFile.rawHeaders.height,1)
		row("unknown")
	textRow("Content:",-1)
		sectionRows("singleForeground","Single Foreground Objects")
		sectionRows("foregroundRows","Foreground Rows")
		sectionRows("foregroundColumns","Foreground Columns")
		if settings.misc.hexInspector.verbosePropertiesDisplay then
			propertyRows("objectProperties","Object Properties",false)
			propertyRows("pathProperties","Path Properties",true)
		else
			sectionRows("objectProperties","Object Properties")
			sectionRows("pathProperties","Path Properties")
		end
		sectionRows("repeatedPropertySets","Repeated Property Sets")
		sectionRows("containedObjects","Contained Objects")
		sectionRows("paths","Paths")
		sectionRows("singleBackground","Single Background Objects")
		sectionRows("backgroundRows","Background Rows")
		sectionRows("backgroundColumns","Background Columns")
		textRow("Hash:")
			textRow(bytesToHex(self.levelFile.raw:sub(c.backgroundColumns.endOffset+1)),1)
end

function UI:inputActivated(name,group, isCursorBound)
	if name=="reload" and group=="misc" then
		self:reload()
	end
end

return UI
