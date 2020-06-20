local PAD = require("ui.structure.padding")

local UI = Class("TreeViewerUI",require("ui.structure.proxy"))

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
	self.list = require("ui.utils.treeList"):new(dataHandler,function(data)
		self:setDetailsUI(dataHandler:getDetailsUI(data))
	end)
	self.details = require("ui.structure.base"):new()
	
	UI.super.initialize(self,require("ui.structure.horDivide"):new(self.list, self.details))
	self.title = "Tree Viewer"
end

function UI:setDetailsUI(ui)
	self.details = ui
	self.child:setRightChild(ui)
end



return UI
