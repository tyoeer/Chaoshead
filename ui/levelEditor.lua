local BaseUI = require("ui.base")

local DET_LEVEL = require("ui.details.level")

local UI = Class(BaseUI)

function UI:initialize(w,h)
	--self.level
	self.viewer = require("ui.worldEditor"):new(-1,-1,nil,self)
	self.detailsUI = require("ui.structure.tabs"):new(-1,-1)
	self.detailsUI:addChild(DET_LEVEL:new(-1,-1))
	self.rootUI = require("ui.structure.horDivide"):new(
		w,h, self.detailsUI, self.viewer
	)
	self.rootUI.parent = self
	
	UI.super.initialize(self,w,h)
	self.title = "Level Editor"
end

function UI:addTab(tab)
	self.detailsUI:addChild(tab)
	self.detailsUI:setActive(tab)
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

function UI:keypressed(key, scancode, isrepeat)
	if key=="r" then
		require("utils.levelUtils").reload()
	else
		self.rootUI:keypressed(key, scancode, isrepeat)
	end
end
relay("textinput")

relay("mousepressed")
relay("mousereleased")
relay("mousemoved")
relay("wheelmoved")



return UI
