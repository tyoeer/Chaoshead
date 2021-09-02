--local LEVEL_ROOT = require("ui.level.levelRoot")
local TABS = require("ui.layout.tabs")
local PROXY = require("ui.base.proxy")
local LEVEL_SELECTOR = require("ui.levelSelector")
local DETAILS = require("ui.tools.details")
local MISC = require("ui.misc")

local UI = Class(require("ui.tools.modal"))

function UI:initialize()
	self.mainTabs = TABS:new()
	
	self.nLevels = 0
	self.levels = TABS:new()
	self.levels.title = "Level Editors"
	self.noLevelsUI = DETAILS:new(false)
	self.noLevelsUI:getList():addTextEntry("No Levels opened!")
	self.noLevelsUI.title = "Level Editors"
	self.levelsProxy = PROXY:new(self.noLevelsUI)
	self.mainTabs:addTab(self.levelsProxy)
	
	local levelSelector = LEVEL_SELECTOR:new()
	self.mainTabs:addTab(levelSelector)
	
	self.mainTabs:addTab(MISC:new())
	
	self.mainTabs:setActiveTab(levelSelector)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,self.mainTabs)
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
			self:displayMessage("Failed to load level!\nError message:\n"..tostring(message))
		end
	)
	if success then
		self.levels:addChild(editor)
		self.levels:setActive(editor)
		self.mainTabs:setActive(self.levelsProxy)
		self.nLevels = self.nLevels + 1
		if self.nLevels == 1 then
			self.levelsProxy:setChild(self.levels)
		end
	end
end

function UI:closeEditor(editorRoot)
	self.levels:removeChild(editorRoot)
	self.nLevels = self.nLevels - 1
	if self.nLevels == 0 then
		self.levelsProxy:setChild(self.noLevelsUI)
	end
end


return UI
