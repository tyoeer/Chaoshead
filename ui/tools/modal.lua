local LIST = require("ui.layout.list")
local BOX = require("ui.layout.box")
local BLOCK = require("ui.layout.block")

local UI = Class("ModalManagerUI",require("ui.base.container"))

local theme = Settings.theme.modal

function UI:initialize(child)
	UI.super.initialize(self)
	--self.modal
	--self.cancelAction
	--the stuff behind the modal
	self.main = BLOCK:new(child, theme.blockStyle)
	self:addChild(self.main)
end

-- modal changing

function UI:setModalRaw(ui)
	self.main:setBlock(true)
	self:addChild(ui)
	self.modal = ui
	self:resizeModal()
end

function UI:setModal(ui)
	self:setModalRaw(BOX:new(ui, theme.boxStyle))
end

function UI:resizeModal()
	local modalWidth = math.ceil(theme.widthFactor * self.width)
	self.modal:resize(modalWidth, self.height)
	
	local x = math.floor((self.width-modalWidth)/2)
	self.modal:move(x,0)
end

function UI:removeModal()
	self.main:setBlock(false)
	self:removeChild(self.modal)
	self:setCancelAction(nil)
	self.modal = nil
end

-- actions

function UI:setCancelAction(cancelAction)
	self.cancelAction = cancelAction
end

-- Preset modals

function UI:displayMessage(...)
	local ui = LIST:new(theme.listStyle)
	for _,item in ipairs({...}) do
		if type(item)=="string" then
			ui:addTextEntry(item)
		else
			ui:addUIEntry(item)
		end
	end
	local dismiss = function() self:removeModal() end
	ui:addButtonEntry("Dismiss", dismiss)
	self:setCancelAction(dismiss)
	self:setModal(ui)
end

-- events

function UI:resized(w,h)
	self.main:resize(w,h)
	if self.modal then
		self:resizeModal()
	end
end

function UI:onInputActivated(name,group,isCursorBound)
	if group=="modal" and self.modal then
		if name=="cancel" and self.cancelAction then
			self.cancelAction(self.modal)
		end
	end
end

return UI
