local BaseUI = require("ui.base")
local DIV = require("ui.structure.horDivide")
local VIEW = require("ui.worldViewer")
local TABS = require("ui.structure.tabs")

local UI = Class(BaseUI)

function UI:initialize(w,h)
	--self.level
	self.viewer = VIEW:new(-1,-1)
	self.detailsUI = TABS:new(-1,-1)
	self.rootUI = DIV:new(w,h, self.detailsUI, self.viewer)
	self.class.super.initialize(self,w,h)
	self.title = "Level Editor"
end

function UI:setLevel(level)
	self.level = level
	self.viewer:setLevel(level)
end

-- events

local relay = function(index)
	UI[index] = function(self, ...)
		self.rootUI[index](self.rootUI, ...)
	end
end

relay("update")

relay("draw")

relay("focus")
relay("visible")
relay("resize")

relay("keypressed")
relay("textinput")

relay("mousepressed")
relay("mousereleased")
relay("mousemoved")
relay("wheelmoved")


return UI
