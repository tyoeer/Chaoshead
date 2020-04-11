local BaseUI = require("ui.base")

local DET_LEVEL = require("ui.details.level")

local UI = Class(BaseUI)

function UI:initialize(w,h)
	--self.level
	self.viewer = require("ui.worldEditor"):new(-1,-1)
	self.detailsUI = require("ui.structure.tabs"):new(-1,-1)
	self.detailsUI:addChild(DET_LEVEL:new(-1,-1))
	self.rootUI = require("ui.structure.horDivide"):new(
		w,h, self.detailsUI,
		require("ui.structure.movableCamera"):new(-1,-1,self.viewer)
	)
	self.rootUI.parent = self
	
	self.class.super.initialize(self,w,h)
	self.title = "Level Editor"
end

function UI:setLevel(level)
	self.level = level
	self.viewer:setLevel(level)
	for child in self.detailsUI.children:iterate() do
		if child.setLevel then
			child:setLevel(level)
		end
	end
end

function UI:addTab(tab)
	self.detailsUI:addChild(tab)
end

function UI:removeTab(tab)
	self.detailsUI:removeChild(tab)
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
function UI:resize(w,h)
	self.width = w
	self.height = h
	self.rootUI:resize(w,h)
end

relay("keypressed")
relay("textinput")

relay("mousepressed")
relay("mousereleased")
relay("mousemoved")
relay("wheelmoved")


return UI
