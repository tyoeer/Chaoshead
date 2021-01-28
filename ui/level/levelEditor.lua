local PAD = require("ui.structure.padding")
local DET_LEVEL = require("ui.level.details.level")
local DET_OBJ = require("ui.level.details.object")
local DET_PN = require("ui.level.details.pathNode")

local UI = Class("LevelEditorUI",require("ui.structure.proxy"))

function UI:initialize(level,root)
	self.level = level
	self.root = root
	--ui state
	self.viewer = require("ui.level.worldEditor"):new(self)
	self.detailsUI = require("ui.structure.tabs"):new()
	self:addTab(DET_LEVEL:new(level,self))
	self.detailsUI.tabHeight = settings.dim.editor.details.tabHeight
	
	--editor state
	self.selectedObject = nil
	self.selectionDetails = nil
	
	UI.super.initialize(self,require("ui.structure.horDivide"):new(self.detailsUI, self.viewer))
	self.title = "Level Editor"
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
	self.viewer:reload(level)
	for c in self.detailsUI.children:iterate() do
		local v = c.child
		if v.reload then v:reload(level) end
	end
end

-- editor stuff
local OBJ = require("levelhead.level.object")
local PATH = require("levelhead.level.path")
local PN = require("levelhead.level.pathNode")

function UI:selectObject(tileX,tileY)
	if self.selectedObject then
		self:deselect()
	end
	local obj = self.level.foreground:get(tileX,tileY) or self.level.background:get(tileX,tileY)
	if obj then
		self.selectedObject = obj
		self.selectionDetails = DET_OBJ:new(obj)
		self:addTab(self.selectionDetails)
	else
		obj = self.level.pathNodes[tileX][tileY]
		if obj then
			self.selectedObject = obj
			self.selectionDetails = DET_PN:new(obj)
			self:addTab(self.selectionDetails)
		end
	end
end

function UI:deselect()
	self.selectedObject = nil
	self:removeTab(self.selectionDetails)
	self.selectionDetails = nil
end

function UI:delete(obj)
	if obj:isInstanceOf(OBJ) then
		self.level:removeObject(obj)
	elseif obj:isInstanceOf(PN) then
		local p = obj.path
		p:removeNode(obj)
		--removed all nodes?
		if not p.tail then
			self.level:removePath(p)
		end
	end
	if obj == self.selectedObject then
		self:deselect()
	end
end

-- events (most are handled by the proxy super)

function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" and name=="delete" then
		if self.selectedObject then
			self:delete(self.selectedObject)
		end
	else
		self.child:inputActivated(name,group, isCursorBound)
	end
end

return UI
