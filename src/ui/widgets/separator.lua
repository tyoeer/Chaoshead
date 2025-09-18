---@class SeparatorUI : BaseNodeUI
---@field super BaseNodeUI
---@field new fun(self: self, height: number): self
local UI = Class("TextUI",require("ui.base.node"))


function UI:initialize(size)
	UI.super.initialize(self)
	self:setSize(size)
end

---@param size number
function UI:setSize(size)
	self.size = size
end

function UI:getMinimumHeight(_width)
	return self.size
end


return UI
