local SCROLL = require("ui.tools.scrollbar")
local HOR_DIVIDE = require("ui.layout.horDivide")
local LIST = require("ui.tools.treeList")
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
			- action: will get called on click (with data as arg) instead of getting details UI

]]--

local theme = settings.theme.treeViewer

function UI:initialize()
	--ui state
	self.list = LIST:new(self, function(data)
		self:setDetailsUI(self:getDetailsUI(data))
	end)
	self.details = BASE:new()
	
	UI.super.initialize(self,HOR_DIVIDE:new(
		SCROLL:new(self.list), self.details,
		theme.listDetailsDivisionStyle
	))
end

function UI:setDetailsUI(ui)
	self.details = ui
	self.child:setRightChild(ui)
end



return UI
