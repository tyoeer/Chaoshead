local P = require("levelhead.data.properties")
--editor tools
local Selection = require("tools.selection.tracker")
local Clipboard = require("tools.clipboard")
--misc UIs
local HorDivide = require("ui.layout.horDivide")
local Tabs = require("ui.tools.tabs")
--specific UIs
local WorldEditor = require("levelEditor.worldEditor")
local SelectionDetails = require("levelEditor.details.selection")
local LevelDetails = require("levelEditor.details.level")

local UI = Class("LevelEditorUI",require("ui.base.proxy"))

local theme = Settings.theme.levelEditor

function UI:initialize(level,root)
	self.level = level
	self.root = root
	--ui state
	self.viewer = WorldEditor:new(self)
	self.detailsUI = Tabs:new()
	self.levelDetails = LevelDetails:new(level,self)
	self:addTab(self.levelDetails)
	
	--editor state
	self.selection = nil
	self.selectionDetails = nil
	self.hand = nil
	
	UI.super.initialize(self, HorDivide:new(
		self.detailsUI, self.viewer,
		theme.detailsWorldDivisionStyle
	))
	self.title = "Level Editor"
end


function UI:addTab(tab)
	tab.editor = self
	self.detailsUI:addTab(tab)
	self.detailsUI:setActiveTab(tab)
end

function UI:removeTab(tab)
	self.detailsUI:removeTab(tab)
end

function UI:reload(level)
	self.level = level
	self.viewer:reload(level)
	self.levelDetails:reload(level)
	if self.selection then
		self:deselectAll()
	end
end

-- private editor stuff

--mask is optional
function UI:newSelection(mask)
	self.selection = Selection:new(self.level,mask)
	self.selectionDetails = SelectionDetails:new(self.selection)
	self:addTab(self.selectionDetails)
end


-- public editor stuff

-- selection manipulation

function UI:selectOnly(tileX,tileY)
	if self.selection then
		self:deselectAll()
	end
	--deselectAll() destroys the selection
	self:newSelection()
	self.selection:add(tileX,tileY)
	self.selectionDetails:reload()
end

function UI:selectAdd(tileX,tileY)
	if self.selection then
		self.selection:add(tileX,tileY)
		self.selectionDetails:reload()
	else
		self:selectOnly(tileX,tileY)
	end
end

function UI:selectAddArea(startX,startY,endX,endY)
	if not self.selection then
		self:newSelection()
	end
	for x = startX, endX, 1 do
		for y = startY, endY, 1 do
			self.selection:add(x,y)
		end
	end
	self.selectionDetails:reload()
end

function UI:selectAll()
	if not self.selection then
		self:newSelection()
	end
	--select everything in bounds
	for x=self.level.left, self.level.right, 1 do
		for y=self.level.top, self.level.bottom, 1 do
			self.selection:add(x,y)
		end
	end
	--select all the objects (they can be out-of-bounds)
	for obj in self.level.objects:iterate() do
		self.selection:add(obj.x,obj.y)
	end
	--select all the path nodes (they can be out-of-bounds)
	for path in self.level.paths:iterate() do
		for node in path:iterateNodes() do
			self.selection:add(node.x,node.y)
		end
	end
	self.selectionDetails:reload()
end

function UI:deselectSub(tileX,tileY)
	if self.selection then
		self.selection:remove(tileX,tileY)
		if self.selection.mask.nTiles==0 then
			self:deselectAll()
		else
			self.selectionDetails:reload()
		end
	end
end

function UI:deselectSubArea(startX,startY,endX,endY)
	if not self.selection then
		return nil
	end
	for x = startX, endX, 1 do
		for y = startY, endY, 1 do
			self.selection:remove(x,y)
		end
	end
	if self.selection.mask.nTiles==0 then
		self:deselectAll()
	else
		self.selectionDetails:reload()
	end
end

function UI:deselectAll()
	if self.selection then
		self.selection = nil
		self:removeTab(self.selectionDetails)
		self.selectionDetails = nil
	end
end

function UI:removeSelectionLayer(layer)
	self.selection:removeLayer(layer)
	self.selectionDetails:reload()
end


-- do stuff with the selection

function UI:deleteSelection()
	if self.selection then
		local c = self.selection.contents
		
		if self.selection:hasLayer("foreground") then
			for obj in c.foreground:iterate() do
				self.level:removeObject(obj)
			end
		end
		if self.selection:hasLayer("background") then
			for obj in c.background:iterate() do
				self.level:removeObject(obj)
			end
		end
		if self.selection:hasLayer("pathNodes") then
			for node in c.pathNodes:iterate() do
				local p = node.path
				p:removeNode(node)
				--removed all nodes?
				if not p.tail then
					self.level:removePath(p)
				end
			end
		end
		
		self.selection = nil
		self:removeTab(self.selectionDetails)
		self.selectionDetails = nil
	end
end

function UI:changeProperty(id, val, op)
	op = op or "="
	if self.selection then
		local pl = self.selection.contents.properties[id]
		for obj in pl.pool:iterate() do
			local old = obj:getPropertyRaw(id)
			local new
			if op=="=" then
				new = val
			elseif op=="+" then
				new = old + val
			elseif op=="-" then
				new = old - val
			elseif op=="*" then
				new = old * val
			elseif op=="/" then
				new = old / val
			else
				error("Ivalid operator "..tostring(op),2)
			end
			if P:getSaveFormat(id)~="C" then
				new = math.floor(new+0.5)
			end
			obj:setPropertyRaw(id, new)
		end
		pl:findBounds()
		self.selectionDetails:reload()
	end
end

function UI:copy()
	if self.selection then
		local cp = Clipboard:new(self.level, self.selection.mask)
		self.root:setClipboard(cp)
	end
end

function UI:cut()
	if self.selection then
		self:copy()
		self:deleteSelection()
	end
end

-- hand stuff

function UI:hold(item)
	self.hand = item
	self.viewer:initHand()
end

function UI:releaseHold()
	self.hand = nil
	self.viewer:clearHand()
end

function UI:place(x,y,release)
	self.hand:copy(self.hand.world, self.level, 0,0, x,y)
	if release then
		self:releaseHold()
	end
end

-- other stuff

function UI:paste()
	local cp = self.root:getClipboard()
	if cp then
		self:hold(cp)
	else
		MainUI:displayMessage("Nothing on clipboard to paste!")
	end
end

function UI:resizeLevel(top,right,bottom,left)
	self.level.top = top
	self.level.right = right
	self.level.bottom = bottom
	self.level.left = left
	self.levelDetails:reload()
end


-- EVENTS (most are handled by the proxy super)

function UI:onInputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="delete" then
			self:deleteSelection()
		elseif name=="deselectAll" then
			self:deselectAll()
		elseif name=="selectAll" then
			self:selectAll()
		elseif name=="copy" then
			self:copy()
		elseif name=="paste" then
			self:paste()
		elseif name=="cut" then
			self:cut()
		end
	end
end

return UI
