local UI = Class(require("ui.structure.list"))

function UI:initialize(level,editor)
	self.editor = editor
	UI.super.initialize(self)
	self.title = "Level Info"
	
	self.entryMargin = settings.dim.editor.details.level.entryMargin
	self.indentSize = settings.dim.editor.details.level.textEntryIndentSize
	
	self:reload(level)
end

function UI:reload(level)
	self:resetList()
	
	self:addTextEntry("Width:  "..level.width)
	self:addTextEntry("Height: "..level.height)
	self:addButtonEntry(
		"Save Level",
		function()
			self.editor.root:save()
		end,
		settings.dim.editor.details.level.buttonPadding
	)
	self:addButtonEntry(
		"Reload Level",
		function()
			self.editor.root:reload()
		end,
		settings.dim.editor.details.level.buttonPadding
	)
	self:addButtonEntry(
		"Close editor (without saving)",
		function()
			self.editor.root:close()
		end,
		settings.dim.editor.details.level.buttonPadding
	)
end

return UI
