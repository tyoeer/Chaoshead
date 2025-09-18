local OptionalScrollbar = require("ui.tools.optionalScrollbar")
local HorDivide = require("ui.layout.horDivide")
local TreeList = require("ui.tools.treeList")
local Base = require("ui.base.node")

---@class TreeViewer.DataHandler : TreeList.DataRetriever
---@field getDetailsUI fun(self: self, data: TreeListEntry): BaseNodeUI

---@class TreeViewerUI : ProxyUI, TreeViewer.DataHandler
---@field super ProxyUI
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

local theme = Settings.theme.treeViewer

function UI:initialize()
	--make subclasses remember which folders are opened
	if self.class.name~="TreeViewerUI" then
		self.persistant = self.class.name
	end
	--ui state
	self.list = TreeList:new(self, function(data)
		self:setDetailsUI(self:getDetailsUI(data))
	end)
	--can't use :resetDetails() because we don't have a child yet
	self.details = Base:new()
	
	UI.super.initialize(self,HorDivide:new(
		OptionalScrollbar:new(self.list), self.details,
		theme.listDetailsDivisionStyle
	))
end

function UI:resetDetails()
	self:setDetailsUI(Base:new())
end

function UI:reload()
	self.list:reload()
end

function UI:setDetailsUI(ui)
	self.details = ui
	self.child:setRightChild(ui)
end



return UI
