local Button = require("ui.widgets.button")
local Text = require("ui.widgets.text")

local UI = Class("TabsUI",require("ui.base.container"))

function UI:initialize(tabHeight)
	UI.super.initialize(self)
	self.tabContents = {}
	--the buttons that set their corresponding tab as the active one
	self.tabButtons = {}
	self.tabHeight = tabHeight
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
		button:resize(tabWidth,self.tabHeight)
		button:move((i-1)*tabWidth, 0)
	end
	-- stretch the last button to make sure it covers the entire UI and doesn't leave some empty pixels on the right
	-- which are caused by the floor in the tabWidth calculation when the the available space doesn't divide nicely
	local leftOverWidth = self.width - #self.tabButtons * tabWidth
	self.tabButtons[#self.tabButtons]:resize(tabWidth + leftOverWidth, self.tabHeight)
end

--set the ui.title field to provide a label for the button
function UI:addTab(ui)
	local label = Text:new(self:getTitle(ui),0,"center","center")
	local b = Button:new(label,function()
		--referencing self here works
		self:setActiveTab(ui)
	end, 0)
	self:addChild(b)
	table.insert(self.tabButtons,b)
	self:updateButtons()
	
	table.insert(self.tabContents,ui)
	
	if not self.activeTab then
		self:setActiveTab(ui)
	end
end

function UI:updateActiveTab()
	--if tabHeight=30, the tabs covers pixels 0-29, and the content should start at pixel 30, aka tabHeight
	self.activeTab:move(0,self.tabHeight)
	self.activeTab:resize(self.width, self.height-self.tabHeight)
end

function UI:removeActiveTab()
	self.activeTab:visible(false)
	self:removeChild(self.activeTab)
	self.activeTab = nil
end

function UI:setActiveTab(ui)
	--it is nil when this function is called for the first time to set the first one
	if self.activeTab then
		self:removeActiveTab()
	end
	self.activeTab = ui
	self:addChild(ui)
	self:updateActiveTab()
	ui:visible(true)
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

return UI
