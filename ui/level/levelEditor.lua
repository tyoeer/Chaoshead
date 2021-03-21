local Padding = require("ui.structure.padding")
local LevelDetails = require("ui.level.details.level")
local OBJ = require("levelhead.level.object")
local ObjectDetails = require("ui.level.details.object")
local PN = require("levelhead.level.pathNode")
local PATH = require("levelhead.level.path")
local PathNodeDetails = require("ui.level.details.pathNode")
local Selection = require("tools.selection.tracker")
local SelectionDetails = require("ui.level.details.selection")

local UI = Class("LevelEditorUI",require("ui.structure.proxy"))

function UI:initialize(level,root)
	self.level = level
	self.root = root
	--ui state
	self.viewer = require("ui.level.worldEditor"):new(self)
	self.detailsUI = require("ui.structure.tabs"):new()
	self:addTab(LevelDetails:new(level,self))
	self.detailsUI.tabHeight = settings.dim.editor.details.tabHeight
	
	--editor state
	self.selection = nil
	self.selectionDetails = nil
	
	UI.super.initialize(self,require("ui.structure.horDivide"):new(self.detailsUI, self.viewer))
	self.title = "Level Editor"
end

function UI:addTab(tab)
	tab.editor = self
	tab = Padding:new(tab, settings.dim.editor.details.inset)
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

-- selection manipulation

function UI:selectOnly(tileX,tileY)
	if self.selection then
		self:deselectAll()
	end
	self.selection = Selection:new(self.level)
	self.selection:add(tileX,tileY)
	self.selectionDetails = SelectionDetails:new(self.selection)
	self:addTab(self.selectionDetails)
end

function UI:selectAdd(tileX,tileY)
	if self.selection then
		self.selection:add(tileX,tileY)
		self.selectionDetails:reload()
	else
		self:selectOnly(tileX,tileY)
	end
end

function UI:removeSelectionLayer(layer)
	self.selection:removeLayer(layer)
	self.selectionDetails:reload()
end

function UI:deselectAll()
	self.selection = nil
	self:removeTab(self.selectionDetails)
	self.selectionDetails = nil
end


-- do stuff with the selection

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
	print("TODO delete handling the object being selected")
end

-- events (most are handled by the proxy super)

function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="delete" then
			print("TODO selection deletion")
		elseif name=="deselectAll" then
			self:deselectAll()
		else
			self.child:inputActivated(name,group, isCursorBound)
		end
	else
		self.child:inputActivated(name,group, isCursorBound)
	end
end

return UI
