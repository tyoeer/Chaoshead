local LIST = require("ui.layout.list")

local UI = Class("DetailsUI",require("ui.layout.padding"))

function UI:initialize(autoLoad)
	self.list = LIST:new(
		settings.theme.details.listStyle
	)
	--also load on nil/unspecified
	if autoLoad~=false then
		self:reload()
	end
	
	UI.super.initialize(
		self,
		self.list,
		settings.theme.details.insetSize
	)
end

--provide access to the underlying list
function UI:getList()
	return self.list
end

--reload hook
function UI:reload(...)
	self:onReload(self.list, ...)
	--it could get reloaded (ex.: autoLoad) before added to the UI tree
	if self.parent then
		self:minimumHeightChanged()
	end
end

-- :onReload() should be defined by the subclass

return UI
