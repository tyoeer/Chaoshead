--local LEVEL_ROOT = require("ui.level.levelRoot")
local TABS = require("ui.tools.tabs")
--local LEVEL_ROOT = require("levelEditor.level.levelRoot")
local LEVEL_SELECTOR = require("levelEditor.workshop.levelSelector")

local UI = Class("WorkshopUI",require("ui.base.proxy"))

function UI:initialize()
	local tabs = TABS:new()
	
	self.levelSelector = LEVEL_SELECTOR:new(self)
	tabs:addTab(self.levelSelector)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,tabs)
	self.title = "Workshop"
end


function UI:openEditor(path)
	local success, editor = xpcall(
		function()
			return LEVEL_ROOT:new(path)
		end,
		function(message)
			message = tostring(message)
			--part of snippet yoinked from default löve error handling
			local fullTrace = debug.traceback():gsub("\n[^\n]+$", "")
			print(fullTrace)
			--cut of the part of the trace that goes into the code that calls UI:openEditor()
			local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
			trace = fullTrace:sub(1,index-1)
			ui:displayMessage("Failed to load level!","Error message: "..message,trace)
		end
	)
	if success then
		self.child:addTab(editor)
		self.child:setActive(self.levelsProxy)
	end
end

function UI:closeEditor(editorRoot)
	if editorRoot==self.child:getActiveTab() then
		self.child:setActiveTab(self.levelSelector)
	end
	self.child:removeChild(editorRoot)
end


return UI
