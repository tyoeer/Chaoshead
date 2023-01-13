-- --editor tools
local EP = require("libs.tyoeerUtils.entitypool")
local LhData = require("levelhead.dataFile")
local LhMisc = require("levelhead.misc")
--misc UIs
local HorDivide = require("ui.layout.horDivide")
local Tabs = require("ui.tools.tabs")
--specific UIs
local Map = require("campaignEditor.map")
local SelectionDetails = require("campaignEditor.details.selection")
local CampaignDetails = require("campaignEditor.details.campaign")

local UI = Class("LevelEditorUI",require("ui.base.proxy"))

local theme = Settings.theme.editor

function UI:initialize(root)
	self.root = root
	self.campaign = root.campaign
	--ui state
	self.viewer = Map:new(self)
	self.detailsUI = Tabs:new()
	self.campaignDetails = CampaignDetails:new(self.campaign,self)
	self:addTab(self.campaignDetails)
	
	--editor state
	-- self.selection = nil
	-- self.selectionSize = 0
	-- self.selectionDetails = nil
	-- self.hand = nil
	
	UI.super.initialize(self, HorDivide:new(
		self.detailsUI, self.viewer,
		theme.detailsWorldDivisionStyle
	))
	self.title = "Map Editor"
end


function UI:addTab(tab)
	tab.editor = self
	self.detailsUI:addTab(tab)
	self.detailsUI:setActiveTab(tab)
end

function UI:removeTab(tab)
	self.detailsUI:removeTab(tab)
end

function UI:reload(campaign)
	self.campaign = campaign
	self.viewer:reload(campaign)
	self.campaignDetails:reload(campaign)
	if self.selection then
		self:deselectAll()
	end
end

-- private editor stuff

function UI:newSelection()
	self.selection = EP:new()
	self.selectionSize = 0
	self.selectionDetails = SelectionDetails:new(self) -- editor also gets set in addTab(), but it requires acces to the editor/selection to properly initialize
	self:addTab(self.selectionDetails)
end

-- function UI:refreshSelection()
-- 	if self.selection then
-- 		self.selection = Selection:new(self.level, self.selection.mask)
-- 		self.selectionDetails:setSelectionTracker(self.selection)
-- 	end
-- end

-- public editor stuff

-- selection manipulation

function UI:selectNode(node)
	self:newSelection()
	self.selection:add(node)
	self.selectionSize = 1
	self.selectionDetails:reload()
end

function UI:selectOnly(x,y)
	if self.selection then
		self:deselectAll()
	end
	local node = self.campaign:getNodeAt(x,y)
	if node then
		self:selectNode(node)
	end
end

function UI:selectAdd(x,y)
	if self.selection then
		local node = self.campaign:getNodeAt(x,y)
		if node then
			if self.selection:add(node) then
				self.selectionSize = self.selectionSize + 1
			end
			self.selectionDetails:reload()
		end
	else
		self:selectOnly(x,y)
	end
end

function UI:selectAddArea(startX,startY,endX,endY)
	if not self.selection then
		self:newSelection()
	end
	for _, node in ipairs(self.campaign:getNodesIn(startX,startY,endX,endY)) do
		if self.selection:add(node) then
			self.selectionSize = self.selectionSize + 1
		end
	end
	self.selectionDetails:reload()
end

function UI:selectAll()
	self:newSelection()
	for node in self.campaign.nodes:iterate() do
		self.selection:add(node)
		-- Don't need to check if selection already has it 'cause we reset it
		self.selectionSize = self.selectionSize + 1
	end
	self.selectionDetails:reload()
end

function UI:deselectSub(x,y)
	if self.selection then
		local node = self.campaign:getNodeAt(x,y)
		if node then
			if self.selection:remove(node) then
				self.selectionSize = self.selectionSize - 1
			end
			if self.selectionSize==0 then
				self:deselectAll()
			else
				self.selectionDetails:reload()
			end
		end
	end
end

function UI:deselectSubArea(startX,startY,endX,endY)
	if not self.selection then
		return
	end
	for _, node in ipairs(self.campaign:getNodesIn(startX,startY,endX,endY)) do
		if self.selection:remove(node) then
			self.selectionSize = self.selectionSize - 1
		end
	end
	if self.selectionSize==0 then
		self:deselectAll()
	else
		self.selectionDetails:reload()
	end
end

function UI:deselectAll()
	if self.selection then
		self.selection = nil
		self.selectionSize = -1
		self:removeTab(self.selectionDetails)
		self.selectionDetails = nil
	end
end

-- do things with the selection

function UI:setLevel(level)
	if self.selection then
		for node in self.selection:iterate() do
			if node.type=="level" then
				node:setLevel(level)
			end
		end
		self.selectionDetails:reload()
		self.root:levelChanged(level) --it's associated nodes changed
	end
end

-- other stuff

function UI:importGameMap()
	local data = LhData:new(LhMisc:getDataPath().."CampaignMaster/LHCampaignMaster")
	self.campaign:reloadNodes(data.raw.nodes)
	self.root:reload(self.campaign)
end

-- filter

-- function UI:removeSelectionLayer(layer)
-- 	self.selection:removeLayer(layer)
-- 	self.selectionDetails:reload()
-- end

-- function UI:filter(prop, filterValue, operation)
-- 	if self.selection then
-- 		local pl = self.selection.contents.properties[prop]
-- 		for obj in pl.pool:iterate() do
-- 			local actualValue = obj:getPropertyRaw(prop)
-- 			local allow = true
-- 			if operation=="==" then
-- 				allow = actualValue==filterValue
-- 			elseif operation=="!=" then
-- 				allow = actualValue~=filterValue
-- 			elseif operation==">" then
-- 				allow = actualValue>filterValue
-- 			elseif operation==">=" then
-- 				allow = actualValue>=filterValue
-- 			elseif operation=="<" then
-- 				allow = actualValue<filterValue
-- 			elseif operation=="<=" then
-- 				allow = actualValue<=filterValue
-- 			end
-- 			if not allow then
-- 				--edit mask to prevent update at every obj that gets edited
-- 				self.selection.mask:remove(obj.x, obj.y)
-- 			end
-- 		end
-- 		self:refreshSelection() --handles mask changes
-- 		return self.selection.contents.properties[prop] -- so the modal can update itself
-- 	end
-- end

-- do stuff with the selection

-- function UI:deleteSelection()
-- 	if self.selection then
-- 		local c = self.selection.contents
		
-- 		if self.selection:hasLayer("foreground") then
-- 			for obj in c.foreground:iterate() do
-- 				self.level:removeObject(obj)
-- 			end
-- 		end
-- 		if self.selection:hasLayer("background") then
-- 			for obj in c.background:iterate() do
-- 				self.level:removeObject(obj)
-- 			end
-- 		end
-- 		if self.selection:hasLayer("pathNodes") then
-- 			for node in c.pathNodes:iterate() do
-- 				local p = node.path
-- 				p:removeNode(node)
-- 				--removed all nodes?
-- 				if not p.tail then
-- 					self.level:removePath(p)
-- 				end
-- 			end
-- 		end
		
-- 		self.selection = nil
-- 		self:removeTab(self.selectionDetails)
-- 		self.selectionDetails = nil
-- 	end
-- end

-- function UI:changeProperty(id, val, op)
-- 	op = op or "="
-- 	if self.selection then
-- 		local pl = self.selection.contents.properties[id]
-- 		for obj in pl.pool:iterate() do
-- 			local old = obj:getPropertyRaw(id)
-- 			local new
-- 			if op=="=" then
-- 				new = val
-- 			elseif op=="+" then
-- 				new = old + val
-- 			elseif op=="-" then
-- 				new = old - val
-- 			elseif op=="*" then
-- 				new = old * val
-- 			elseif op=="/" then
-- 				new = old / val
-- 			else
-- 				error("Ivalid operator "..tostring(op),2)
-- 			end
-- 			if P:getSaveFormat(id)~="C" then
-- 				new = math.floor(new+0.5)
-- 			end
-- 			obj:setPropertyRaw(id, new)
-- 		end
-- 		pl:findBounds()
-- 		self.selectionDetails:reload()
-- 	end
-- end

-- function UI:disconnectNodes()
-- 	for node in self.selection.contents.pathNodes:iterate() do
-- 		local node = self.level.pathNodes[node.x][node.y]
-- 		if node.next and self.selection.mask:has(node.next.x, node.next.y) then
-- 			node:disconnectAfter()
-- 		end
-- 		local node = self.level.pathNodes[node.x][node.y]
-- 		if node.prev and self.selection.mask:has(node.prev.x, node.prev.y) then
-- 			node.prev:disconnectAfter()
-- 		end
-- 	end
-- 	self:refreshSelection()
-- end

-- function UI:connectNodes()
-- 	local a = self.selection.contents.pathNodes:getTop()
-- 	local b = self.selection.contents.pathNodes:getBottom()
-- 	if a.next and a.prev then
-- 		MainUI:displayMessage(string.format("The path node at (%i,%i) is already connected!",a.x,a.y))
-- 		return
-- 	end
-- 	if b.next and b.prev then
-- 		MainUI:displayMessage(string.format("The path node at (%i,%i) is already connected!",b.x,b.y))
-- 		return
-- 	end
-- 	if a.prev==nil and b.next==nil then
-- 		a,b = b,a
-- 	elseif (a.prev and b.prev) or (a.next and b.next) then
-- 		MainUI:displayMessage("Can't connect: the paths point towards each other!")
-- 		return
-- 	end
-- 	--a is a last node, b is a first
-- 	for prop in a.path:iterateProperties() do
-- 		if a.path:getPropertyRaw(prop)~=b.path:getPropertyRaw(prop) then
-- 			MainUI:displayMessage(string.format("Can't connect: property %s differs!",P:getName(prop)))
-- 			return
-- 		end
-- 	end
	
-- 	if a.path==b.path then
-- 		a.path:setClosed("Yes")
-- 	else
-- 		for node in b.path:iterateNodes() do
-- 			a.path:append(node.x, node.y)
-- 		end
-- 	end
-- 	self:refreshSelection()
-- end

-- function UI:reversePaths()
-- 	local done = {}
-- 	for node in self.selection.contents.pathNodes:iterate() do
-- 		local p = node.path
-- 		if not done[p] then
-- 			p:reverse()
-- 			done[p] = true
-- 		end
-- 	end
-- 	self:refreshSelection()
-- end

-- function UI:copy()
-- 	if self.selection then
-- 		local cp = Clipboard:new(self.level, self.selection.mask)
-- 		self.root:setClipboard(cp)
-- 	end
-- end

-- function UI:cut()
-- 	if self.selection then
-- 		self:copy()
-- 		self:deleteSelection()
-- 	end
-- end

-- hand stuff

-- function UI:hold(item)
-- 	self.hand = item
-- 	self.viewer:initHand()
-- end

-- function UI:releaseHold()
-- 	self.hand = nil
-- 	self.viewer:clearHand()
-- end

-- function UI:place(x,y,release)
-- 	self.hand:copy(self.hand.world, self.level, 0,0, x,y)
-- 	if release then
-- 		self:releaseHold()
-- 	end
-- 	self:refreshSelection()
-- end

-- other stuff

-- function UI:paste()
-- 	local cp = self.root:getClipboard()
-- 	if cp then
-- 		self:hold(cp)
-- 	else
-- 		MainUI:displayMessage("Nothing on clipboard to paste!")
-- 	end
-- end

-- EVENTS (most are handled by the proxy super)

function UI:levelChanged(level)
	self.selectionDetails:reload()
end

function UI:onInputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="delete" then
			-- TODO self:deleteSelection()
		elseif name=="deselectAll" then
			self:deselectAll()
		elseif name=="selectAll" then
			self:selectAll()
		-- elseif name=="copy" then
		-- 	self:copy()
		-- elseif name=="paste" then
		-- 	self:paste()
		-- elseif name=="cut" then
		-- 	self:cut()
		end
	end
end

return UI
