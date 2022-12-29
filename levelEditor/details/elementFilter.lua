local E = require("levelhead.data.elements")
local FilteredList = require("ui.widgets.filteredList")

local UI = Class("ElementFilterUI", require("ui.layout.list"))

local theme = Settings.theme.details

function UI:initialize(editor, selection)
	UI.super.initialize(self, theme.listStyle)
	
	self.editor = editor
	self.filteredList = FilteredList:new(self:buildElementList(selection), theme.listStyle, theme.inputStyle.inputStyle)
	self.filteredList:grabFocus()
	
	self:reload()
end

function UI:buildElementList(s)
	local c = s.contents
	local out = {}
	
	if s.mask:getLayerEnabled("pathNodes") and c.nPathNodes>=1 then
		table.insert(out, "Path node")
	end
	if s.mask:getLayerEnabled("foreground") and s.mask.nTiles>c.nForeground then
		table.insert(out, "Air (foreground)")
	end
	if s.mask:getLayerEnabled("background") and s.mask.nTiles>c.nBackground then
		table.insert(out, "Air (background)")
	end
	if s.mask:getLayerEnabled("pathNodes") and s.mask.nTiles>c.nPathNodes then
		table.insert(out, "Air (path nodes)")
	end
	
	--TODO raw numbers
	local elems = {}
	if s.mask:getLayerEnabled("foreground") then
		for obj in c.foreground:iterate() do
			elems[obj:getName()] = true
		end
	end
	if s.mask:getLayerEnabled("background") then
		for obj in c.background:iterate() do
			elems[obj:getName()] = true
		end
	end
	for k,_ in pairs(elems) do
		table.insert(out, k)
	end
	
	table.sort(out, function (a,b)
		local aSize, aName = a:match("(%d+x%d+) (.+)")
		if not aName then aName = a end
		local bSize, bName = b:match("(%d+x%d+) (.+)")
		if not bName then bName = b end
		if aName==bName then
			if not aSize then
				return true
			elseif not bSize then
				return false
			else
				return aSize < bSize
			end
		else
			return aName < bName
		end
	end)
	
	return out
end

function UI:reload()
	self:resetList()
	
	self:addButtonEntry("Filter selection to element", function()
		local element = self.filteredList:getItem()
		if element then
			self.editor:filterElement(element, true)
			if self.editor.selection then
				self.filteredList:setItemList(self:buildElementList(self.editor.selection))
				self:reload()
			else
				MainUI:removeModal()
			end
		else
			MainUI:displayMessage("Can't filter: no element selected")
		end
	end)
	self:addButtonEntry("Filter element out of selection", function()
		local element = self.filteredList:getItem()
		if element then
			self.editor:filterElement(element, false)
			if self.editor.selection then
				self.filteredList:setItemList(self:buildElementList(self.editor.selection))
				self:reload()
			else
				MainUI:removeModal()
			end
		else
			MainUI:displayMessage("Can't filter: no element selected")
		end
	end)
	
	self:addTextEntry("")
	
	self:addUIEntry(self.filteredList)
	
	--divider between items and dismiss button
	self:addTextEntry("")
end

return UI