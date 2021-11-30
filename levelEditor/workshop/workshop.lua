--local LEVEL_ROOT = require("ui.level.levelRoot")
local TABS = require("ui.tools.tabs")
--local LEVEL_ROOT = require("levelEditor.level.levelRoot")
local LEVEL_SELECTOR = require("levelEditor.workshop.levelSelector")
local LEVEL_ROOT = require("levelEditor.levelRoot")

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
	--open the editor
	local success, editor = xpcall(
		function()
			return LEVEL_ROOT:new(path,self)
		end,
		LEVEL_ROOT.loadErrorHandler
	)
	if success then
		self.child:addTab(editor)
		self.child:setActiveTab(editor)
		--remember we opened this one
		storage.lastLevelOpened = {
			when = os.time(),
			name = editor.level.settings:getTitle(),
			path = path,
		}
		storage.save()
	end
end

function UI:closeEditor(editorRoot)
	if editorRoot==self.child:getActiveTab() then
		self.child:setActiveTab(self.levelSelector)
	end
	self.child:removeTab(editorRoot)
end


return UI
