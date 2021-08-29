local SCROLL = require("ui.layout.scrollbar")
local HOR_DIVIDE = require("ui.layout.horDivide")
local LIST = require("ui.tools.treeList")
local PADDING = require("ui.layout.padding")
local BASE = require("ui.base.node")

local UI = Class("TreeViewerUI",require("ui.base.proxy"))

--[[

dataHandler:
	getDetailsUI(datahandler,data)
		should return a UI node to display on the right
	from treeList:
		getChildren(dataHandler,parent)
			should return all the children of parent
		getRootEntries(dataHandler)
			should return the entries at the root
			
		entry format:
			- title: title to display
			- folder: wether or not this is a folder

]]--

function UI:initialize(dataHandler)
	--ui state
	self.list = LIST:new(dataHandler,function(data)
		self:setDetailsUI(PADDING:new(
			dataHandler:getDetailsUI(data),
			settings.dim.treeViewer.detailsPadding
		))
	end)
	self.details = BASE:new()
	
	UI.super.initialize(self,HOR_DIVIDE:new(
		SCROLL:new(self.list), self.details,
		settings.dim.treeViewer.divisionRatio
	))
end

function UI:setDetailsUI(ui)
	self.details = ui
	self.child:setRightChild(ui)
end



return UI
