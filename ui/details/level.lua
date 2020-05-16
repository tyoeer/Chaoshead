local UI = Class(require("ui.structure.list"))

function UI:initialize()
	UI.super.initialize(self)
	self.title = "Level Info"
	
	self.textEntryVPadding = settings.dim.editor.details.level.textEntryVerticalPadding
	self.indentSize = settings.dim.editor.details.level.textEntryIndentSize
	
	self:reload()
end

function UI:reload()
	self:resetList()
	if level then
		self:addTextEntry("Width:  "..level.width)
		self:addTextEntry("Height: "..level.height)
	else
		self:addTextEntry("No level loaded :(")
	end
end

return UI
