local PAD = require("ui.structure.padding")
local DET_LEVEL = require("ui.details.level")
local DET_OBJ = require("ui.details.object")

local UI = Class("LevelEditorUI",require("ui.structure.proxy"))

function UI:initialize(level,root)
	self.level = level
	self.root = root
	--ui state
	self.viewer = require("ui.worldEditor"):new(self)
	self.detailsUI = require("ui.structure.tabs"):new()
	self:addTab(DET_LEVEL:new(level,self))
	self.detailsUI.tabHeight = settings.dim.editor.details.tabHeight
	
	--editor state
	self.selectedObject = nil
	self.selectionDetails = nil
	
	UI.super.initialize(self,require("ui.structure.horDivide"):new(self.detailsUI, self.viewer))
	self.title = "Level Editor"
	print(self.level)
end

function UI:addTab(tab)
	tab.editor = self
	tab = PAD:new(tab, settings.dim.editor.details.inset)
	self.detailsUI:addChild(tab)
	self.detailsUI:setActive(tab)
end

function UI:removeTab(tab)
	for child in self.detailsUI.children:iterate() do
		if child.child==tab then
			self.detailsUI:removeChild(child)
			break
		end
	end
end

function UI:reload(level)
	self.level = level
	for v in self.detailsUI.children:iterate() do
		if v.reload then v:reload(level) end
	end
end

-- editor stuff

function UI:selectObject(tileX,tileY)
	if self.selectedObject then
		self:deselect()
	end
	local obj = self.level.foreground:get(tileX,tileY)
	if obj then
		self.selectedObject = obj
		self.selectionDetails = DET_OBJ:new(obj)
		self:addTab(self.selectionDetails)
	end
end

function UI:deselect()
	self.selectedObject = nil
	self:removeTab(self.selectionDetails)
	self.selectionDetails = nil
end

function UI:delete(obj)
	self.level:removeObject(obj)
	if obj == self.selectedObject then
		self:deselect()
	end
end

-- events (most are handled by the proxy super)

function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="delete" then
			if self.selectedObject then
				self:delete(self.selectedObject)
			end
		end
	else
		self.child:inputActivated(name,group, isCursorBound)
	end
end


return UI
