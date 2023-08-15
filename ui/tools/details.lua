local LIST = require("ui.layout.list")
local PADDING = require("ui.layout.padding")
local SCROLLBAR = require("ui.tools.optionalScrollbar")

---@class DetailsUI : ProxyUI
---@field super ProxyUI
---@field onReload fun(self, list: ListUI, ...)
---@field new fun(self, autoload: boolean): self
local UI = Class("DetailsUI",require("ui.base.proxy"))

local theme = Settings.theme.details

---@param autoLoad boolean?
function UI:initialize(autoLoad)
	self.list = LIST:new(
		theme.listStyle
	)
	local padding = PADDING:new(self.list, theme.insetSize)
	local scrollbar = SCROLLBAR:new(padding)
	
	--also load on nil/unspecified
	if autoLoad~=false then
		self:reload()
	end
	
	UI.super.initialize(
		self,
		scrollbar
	)
end

--provide access to the underlying list
---@return ListUI
function UI:getList()
	return self.list
end

--reload hook
function UI:reload(...)
	self:onReload(self.list, ...)
	--it could get reloaded (ex.: autoLoad) before added to the UI tree
	if self.parent then
		self.list:minimumHeightChanged()
	end
end

-- :onReload() should be defined by the subclass

return UI
