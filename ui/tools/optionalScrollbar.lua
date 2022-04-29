local Scrollbar = require("ui.tools.scrollbar")

local UI = Class("OptionalScrollbarUI",require("ui.base.proxy"))

function UI:initialize(child)
	UI.super.initialize(self)
	self.contents = child
	--self.scrollbar = nil
	self:updateScrollbar()
end

function UI:updateScrollbar()
	if self.contents:getMinimumHeight(self.width) > self.height then
		if not self.scrollbar then
			self.scrollbar = Scrollbar:new(self.child)
		end
		self:setChild(self.scrollbar)
	else
		self.scrollbar = nil
		self:setChild(self.contents)
	end
end

function UI:childMinimumHeightChanged()
	self:updateScrollbar()
	self:minimumHeightChanged() -- parent might care
end

function UI:resized(w,h)
	self:updateScrollbar()
	UI.super.resized(self, w,h)
end

return UI