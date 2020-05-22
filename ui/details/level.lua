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
		self:addButtonEntry("Save Level",require("utils.levelUtils").save)
		self:addButtonEntry("Reload Level",require("utils.levelUtils").reload)
	else
		self:addTextEntry("No level loaded :(")
		self:addButtonEntry("Reload Level",require("utils.levelUtils").reload)
	end
end

return UI
