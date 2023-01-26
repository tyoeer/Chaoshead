local PropEdit = require("levelEditor.details.propertyEditor")
local Box = require("ui.layout.box")

local UI = Class("PropertyPopupUI", require("ui.tools.tabs"))

function UI:initialize(propertyList, editor)
	UI.super.initialize(self)
	
	self.edit = PropEdit:new(propertyList, editor)
	self:addTab(self.edit)
	
	self.filter = PropEdit:new(propertyList, editor, true)
	self:addTab(self.filter)
end

function UI:popup()
	MainUI:setModal(self, function() MainUI:removeModal() end)
end

return UI