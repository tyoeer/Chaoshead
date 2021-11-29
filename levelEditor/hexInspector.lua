local BaseUI = require("ui.tools.details")

--LevelBytesUI
local UI = Class("HexInspectorUI",BaseUI)

local function bytesToHex(bytes)
	local out = love.data.encode("string","hex",bytes)
	out = out:upper()
	out = out:gsub("(..)","%1 ")
	--remove the last space
	return out:sub(1,-2)
end

function UI:initialize(levelFile)
	self.levelFile = levelFile
	self.indent = 0
	
	UI.super.initialize(self,true)
	self.title = "Hex Inspector"
end

-- Row shortcuts

function UI:textRow(text,extraIndent)
	extraIndent = extraIndent or 0
	self:getList():addTextEntry(text, self.indent+extraIndent)
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
function UI:propertyRows(section, label)
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

function UI:onReload(list,levelFile)
	if levelFile then
		self.levelFile = levelFile
	end
	self.indent = 1
	
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
			self:propertyRows("objectProperties","Object Properties")
			self:propertyRows("pathProperties","Path Properties")
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

return UI
