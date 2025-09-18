local PropEdit = require("levelEditor.details.propertyEditor")
local Box = require("ui.layout.box")

---Combines a property editor and a property filter
---@class PropertyPopupUI : TabsUI
---@field super TabsUI
---@field new fun(self, propertyList: PropertyList, editor: LevelEditorUI): self
local UI = Class("PropertyPopupUI", require("ui.tools.tabs"))

function UI:initialize(propertyList, editor)
	UI.super.initialize(self)
	
	self.edit = PropEdit:new(propertyList, self, editor)
	self:addTab(self.edit)
	
	self.filter = PropEdit:new(propertyList, self, editor, true)
	self:addTab(self.filter)
end

--- Also triggers reloads
function UI:refreshPropertyList(propList)
	self.edit:setPropertyList(propList)
	self.filter:setPropertyList(propList)
end

function UI:popup()
	MainUI:setModal(self, function() MainUI:removeModal() end)
end

return UI