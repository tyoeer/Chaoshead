local LIST = require("ui.layout.list")

local UI = Class("DetailsUI",require("ui.layout.padding"))

function UI:initialize(autoLoad)
	self.list = LIST:new(
		settings.dim.details.entryMargin,
		settings.dim.details.textIndentSize,
		settings.dim.details.buttonPadding
	)
	--also load on nil/unspecified
	if autoLoad~=false then
		self:reload()
	end
	
	UI.super.initialize(
		self,
		self.list,
		settings.dim.details.inset
	)
end

--provide access to the underlying list
function UI:getList()
	return self.list
end

--reload hook
function UI:reload(...)
	self.onReload(self,self.list, ...)
end

-- :onReload() should be defined by the subclass

return UI
