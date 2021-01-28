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
	
	self.indentSize = settings.dim.hexInspector.indentSize
	self.rowHeight = settings.dim.hexInspector.rowHeight
	self.xPadding = settings.dim.hexInspector.xPadding
	self.yPadding = settings.dim.hexInspector.yPadding
	--self.i = 0
	--self.indent = 1
	
	self:reload()
end

function UI:reload(l)
	if l then
		self.levelFile = l
	else
		l = self.levelFile
	end
end



function UI:resetRows()
	self.i = 0
	self.indent = 1
end

function UI:textRow(text,extraIndent)
	extraIndent = extraIndent or 0
	love.graphics.print(text, (self.indent+extraIndent)*self.indentSize +self.xPadding, self.i*self.rowHeight +self.yPadding)
	self.i = self.i +1
end
function UI:headerRow(label,offset,length,extraIndent)
	length = length or 1
	local text = label
	text = text .. ": "
	text = text .. bytesToHex(self.levelFile:getBytes(offset,length))
	self:textRow(text,2+(extraIndent or 0))
end

function UI:sectionRows(section, label)
	self:textRow(label..": ".. self.levelFile.rawContentEntries[section].nEntries)
	for _,v in ipairs(self.levelFile.rawContentEntries[section].entries) do
		local hex = bytesToHex(self.levelFile.raw:sub(v.startOffset,v.endOffset))
		self:textRow(hex,2)
	end
end
function UI:propertyRows(section, label, isPath)
	self:textRow(label..": ".. self.levelFile.rawContentEntries[section].nEntries)
	for _,v in ipairs(self.levelFile.rawContentEntries[section].entries) do
		local hex = bytesToHex(self.levelFile.raw:sub(v.startOffset,v.endOffset))
		self:textRow(hex,2)
		for _,w in ipairs(v.entries) do
			self:textRow("-> "..w.value,2)
			for _,u in ipairs(w.entries) do
				if isPath then
					self:textRow("("..u..")",3)
				else
					self:textRow("("..(u.x+1)..","..(u.y+1)..")",3)
				end
			end
		end
	end
end
function UI:draw()
	self:resetRows(self)
	love.graphics.setColor(1,1,1)
	self:textRow("Headers:",-1)
		local h = self.levelFile.rawHeaders
		self:headerRow("Prefix",1,6)
		self:headerRow("CampaignMarker",7)
		self:headerRow("Settings List",8)
		for i=1, h.settingsList.amount, 1 do
			self:textRow(bytesToHex(self.levelFile:getBytes(h.settingsList.startOffset+(i-1)*2,2)),3)
		end
		self:headerRow("Title", h.titleStartOffset, h.titleEndOffset-h.titleStartOffset+1)
		self:headerRow("Zone", h.titleEndOffset+1)
		self:headerRow("Width", h.titleEndOffset+2)
		self:headerRow("Height", h.titleEndOffset+3)
		self:headerRow("DividerConstant", h.titleEndOffset+4,4)
	self:textRow("Content:",-1)
		self:sectionRows("singleForeground","Single Foreground Objects")
		self:sectionRows("foregroundRows","Foreground Rows")
		self:sectionRows("foregroundColumns","Foreground Columns")
		if settings.misc.hexInspector.verbosePropertiesDisplay then
			self:propertyRows("objectProperties","Object Properties",false)
			self:propertyRows("pathProperties","Path Properties",true)
		else
			self:sectionRows("objectProperties","Object Properties")
			self:sectionRows("pathProperties","Path Properties")
		end
		self:sectionRows("repeatedPropertySets","Repeated Property Sets")
		self:sectionRows("containedObjects","Contained Objects")
		self:sectionRows("paths","Paths")
		self:sectionRows("singleBackground","Single Background Objects")
		self:sectionRows("backgroundRows","Background Rows")
		self:sectionRows("backgroundColumns","Background Columns")
		self:textRow("Hash:")
			self:textRow(bytesToHex(self.levelFile.raw:sub(self.levelFile.rawContentEntries.backgroundColumns.endOffset+1)),1)
end

function UI:inputActivated(name,group, isCursorBound)
	if name=="reload" and group=="misc" then
		self:reload()
	end
end

return UI
