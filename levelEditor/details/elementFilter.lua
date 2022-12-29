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
	---@type FLItem
	local out = {}
	
	if s.mask:getLayerEnabled("pathNodes") and c.nPathNodes>=1 then
		table.insert(out, {
			label = "Path node",
			filter = "path node",
			context = -10
		})
	end
	if s.mask:getLayerEnabled("foreground") and s.mask.nTiles>c.nForeground then
		table.insert(out, {
			label = "Air (foreground)",
			filter = "air (foreground)",
			context = -3
		})
	end
	if s.mask:getLayerEnabled("background") and s.mask.nTiles>c.nBackground then
		table.insert(out, {
			label = "Air (background)",
			filter = "air (background)",
			context = -4
		})
	end
	if s.mask:getLayerEnabled("pathNodes") and s.mask.nTiles>c.nPathNodes then
		table.insert(out, {
			label = "Air (path nodes)",
			filter = "air (path nodes)",
			context = -5
		})
	end
	
	--TODO raw numbers
	local elems = {}
	if s.mask:getLayerEnabled("foreground") then
		for obj in c.foreground:iterate() do
			elems[obj:getName()] = obj.id
		end
	end
	if s.mask:getLayerEnabled("background") then
		for obj in c.background:iterate() do
			elems[obj:getName()] = obj.id
		end
	end
	for elem,id in pairs(elems) do
		table.insert(out, {
			label = elem,
			filter = elem:lower(),
			context = id,
		})
	end
	
	table.sort(out, function (a,b)
		local aSize, aName = a.label:match("(%d+x%d+) (.+)")
		if not aName then aName = a.label end
		local bSize, bName = b.label:match("(%d+x%d+) (.+)")
		if not bName then bName = b.label end
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
	
	self:addSeparator(false)
	
	self:addUIEntry(self.filteredList)
	
	--divider between items and dismiss button
	self:addSeparator(true)
end

return UI