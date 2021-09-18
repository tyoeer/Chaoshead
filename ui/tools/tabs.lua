local Button = require("ui.widgets.button")
local Text = require("ui.widgets.text")

local UI = Class("TabsUI",require("ui.base.container"))

function UI:initialize()
	UI.super.initialize(self)
	self.tabContents = {}
	--the buttons that set their corresponding tab as the active one
	self.tabButtons = {}
	--map the get the button of a specific tab (content)
	self.contentButtonMap = {}
	--self.activeTab
end

function UI:getTitle(ui)
	if ui.title then
		return ui.title
	else
		return "$Class:"..ui.class.name
	end
end

function UI:updateButtons()
	local tabWidth = math.floor(self.width / #self.tabButtons)
	for i,button in ipairs(self.tabButtons) do
		button:resize(tabWidth,settings.theme.tabs.buttonHeight)
		button:move((i-1)*tabWidth, 0)
	end
	-- stretch the last button to make sure it covers the entire UI and doesn't leave some empty pixels on the right
	-- which are caused by the floor in the tabWidth calculation when the the available space doesn't divide nicely
	local leftOverWidth = self.width - #self.tabButtons * tabWidth
	self.tabButtons[#self.tabButtons]:resize(tabWidth + leftOverWidth, settings.theme.tabs.buttonHeight)
end

--set the ui.title field to provide a label for the button
--(not what this function does, it's a tip for users)
function UI:addTab(ui)
	local b = Button:new(self:getTitle(ui), function()
		--referencing self here works
		self:setActiveTab(ui)
	end, settings.theme.tabs.tabButtonStyle)
	self:addChild(b)
	table.insert(self.tabButtons,b)
	self.contentButtonMap[ui] = b
	self:updateButtons()
	
	table.insert(self.tabContents,ui)
	if not self.activeTab then
		self:setActiveTab(ui)
	end
end

function UI:updateActiveTab()
	--if tabHeight=30, the tabs covers pixels 0-29, and the content should start at pixel 30, aka tabHeight
	self.activeTab:move(0,settings.theme.tabs.buttonHeight)
	self.activeTab:resize(self.width, self.height-settings.theme.tabs.buttonHeight)
end

function UI:removeActiveTab()
	self.activeTab:visible(false)
	self:removeChild(self.activeTab)
	self.contentButtonMap[self.activeTab]:setStyle(settings.theme.tabs.tabButtonStyle)
	self.activeTab = nil
end

function UI:setActiveTab(ui)
	--it is nil when this function is called for the first time to set the first one
	if self.activeTab then
		self:removeActiveTab()
	end
	self.activeTab = ui
	self.contentButtonMap[ui]:setStyle(settings.theme.tabs.activeTabButtonStyle)
	self:addChild(ui)
	self:updateActiveTab()
	ui:visible(true)
end

function UI:getActiveTab()
	return self.activeTab
end

function UI:removeTab(ui)
	local n
	for i,tab in ipairs(self.tabContents) do
		if tab==ui then
			n = i
			break
		end
	end
	table.remove(self.tabContents,n)
	table.remove(self.tabButtons,i)
	self.contentButtonMap[ui] = nil
	if ui == self.activeTab then
		--check if there's a tab to make active
		if #self.tabContents >= 1 then
			self:setActiveTab(self.tabContents[1])
		else
			self:removeActiveTab()
		end
	end
end


function UI:resized(w,h)
	self:updateButtons()
	self:updateActiveTab()
end

function UI:onDraw()
	local btn = self.contentButtonMap[self.activeTab]
	love.graphics.setColor(settings.theme.tabs.activeDividerColor)
	--[[
	button start at 30, has width of 10:
	it has pixels 30-39
	pixels to be overwritten are 31-38
	(to not overwrite the part directly below the vertical lines of the outline)
	edges don't have the line width added, so we sghould draw from pixel edge to pixel edge
	the first is btn.x + 1 = 31
	the last is btn.x + btn.width - 1 = 39 (aka the right edge of pixel 38)
	]]
	love.graphics.line(
		btn.x+1, settings.theme.tabs.buttonHeight-0.5,
		btn.x+btn.width-1, settings.theme.tabs.buttonHeight-0.5
	)
end


return UI
