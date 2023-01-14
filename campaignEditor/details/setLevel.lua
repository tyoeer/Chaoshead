local FilteredList = require("ui.widgets.filteredList")

local UI = Class("CampaignNodeSetLevel", require("ui.layout.list"))

local theme = Settings.theme.details

function UI:initialize(editor)
	UI.super.initialize(self, theme.listStyle)
	
	self.editor = editor
	self.filteredList = FilteredList:new(self:buildLevelList(), theme.listStyle, theme.inputStyle.inputStyle)
	self.filteredList:grabFocus()
	
	self:reload()
end

function UI:buildLevelList()
	local out = {}
	
	for level in self.editor.campaign.levels:iterate() do
		table.insert(out, {
			label = level:getLabel(),
			filter = level.id:lower(),
			context = level,
		})
	end
	
	table.sort(out, function(a,b)
		return a.label < b.label
	end)
	
	return out
end

function UI:reload()
	self:resetList()
	
	self:addButtonEntry("Set level", function()
		local level = self.filteredList:getItem()
		if level then
			self.editor:setLevel(level)
			MainUI:removeModal()
		else
			MainUI:popup("Select a level first")
		end
	end)
	
	self:addSeparator(false)
	
	self:addUIEntry(self.filteredList)
	
	--divider between items and dismiss button
	self:addSeparator(true)
end

return UI