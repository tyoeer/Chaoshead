local Tabs = require("ui.tools.tabs")
local FileExplorer = require("dataExplorer.fileExplorer")

local TableViewer = require("dataExplorer.viewers.table")
local TextViewer = require("dataExplorer.viewers.text")
local DataFileViewer = require("dataExplorer.viewers.dataFile")
local JSONViewer = require("dataExplorer.viewers.json")
local LHSHexInspector = require("dataExplorer.viewers.hexInspector")

local UI = Class("DataExplorerUI",require("ui.base.proxy"))

function UI:initialize()
	local tabs = Tabs:new()
	
	self.fileExplorer = FileExplorer:new(self)
	tabs:addTab(self.fileExplorer)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,tabs)
	
	self.title = "Data Explorer"
end

function UI:openTextViewer(path)
	local ui = TextViewer:new(path,self)
	ui.title = path
	self.child:addTab(ui)
	self.child:setActiveTab(ui)
end

function UI:openLHSHexInspector(path)
	local ui = LHSHexInspector:new(path,self)
	ui.title = path
	self.child:addTab(ui)
	self.child:setActiveTab(ui)
end

function UI:openJSONViewer(path)
	local ui = JSONViewer:new(path,self)
	ui.title = path
	self.child:addTab(ui)
	self.child:setActiveTab(ui)
end

function UI:openDataFileViewer(path)
	local ui = DataFileViewer:new(path,self)
	ui.title = path
	self.child:addTab(ui)
	self.child:setActiveTab(ui)
end

function UI:openDataViewer(data, label)
	local ui = TableViewer:new(data,self)
	ui.title = label
	self.child:addTab(ui)
	self.child:setActiveTab(ui)
end

function UI:closeViewer(viewerUI)
	if viewerUI==self.child:getActiveTab() then
		self.child:setActiveTab(self.fileExplorer)
	end
	self.child:removeTab(viewerUI)
end

return UI
