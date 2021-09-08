--local LEVEL_ROOT = require("ui.level.levelRoot")
local TABS = require("ui.layout.tabs")
--local LEVEL_ROOT = require("levelEditor.level.levelRoot")
local LEVEL_SELECTOR = require("levelEditor.levelSelector")

local UI = Class("WorkshopUI",require("ui.base.proxy"))

function UI:initialize()
	local tabs = TABS:new()
	
	self.levelSelector = LEVEL_SELECTOR:new()
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
			--print full trace to console
			--snippet yoinked from default löve error handling
			print((debug.traceback("Error loading level: " .. tostring(message), 1):gsub("\n[^\n]+$", "")))
			ui:displayMessage("Failed to load level!\nError message:\n"..tostring(message))
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
