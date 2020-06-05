local BaseUI = require("ui.base")

local PAD = require("ui.structure.padding")
local DET_LEVEL = require("ui.details.level")
local DET_OBJ = require("ui.details.object")

local UI = Class(BaseUI)

function UI:initialize(child)
	self.child = child
	child.parent = self
	
	UI.super.initialize(self)
	self.title = "Level Editor"
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
