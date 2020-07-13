local BaseUI = require("ui.structure.base")
local UI = Class("ProxyUI",BaseUI)

function UI:initialize(child)
	self.child = child
	child.parent = self
	
	UI.super.initialize(self)
	self.title = child.title
end

function UI:setChild(child)
	if self.child then
		self.child.parent = nil
	end
	self.child = child
	child.parent = self
	child:resize(self.width, self.height)
	self.title = child.title
end

-- events

local relay = function(index)
	UI[index] = function(self, ...)
		self.child[index](self.child, ...)
	end
end


relay("update")

relay("draw")

relay("focus")
relay("visible")
function UI:resize(w,h)
	self.width = w
	self.height = h
	self.child:resize(w,h)
end

relay("inputActivated")
relay("inputDeactivated")

relay("textinput")

relay("mousemoved")
relay("wheelmoved")


return UI
