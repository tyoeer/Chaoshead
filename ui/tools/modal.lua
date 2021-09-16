local LIST = require("ui.layout.list")
local BOX = require("ui.layout.box")
local BLOCK = require("ui.utils.block")

local UI = Class(require("ui.base.container"))

function UI:initialize(child)
	UI.super.initialize(self)
	--self.modal
	--the stuff behind the modal
	self.main = BLOCK:new(child)
	self:addChild(self.main)
end

function UI:setModalRaw(ui)
	self.main:setBlock(true)
	self:addChild(ui)
	self.modal = ui
	self:resizeModal()
end

function UI:setModal(ui)
	self:setModalRaw(BOX:new(ui, settings.theme.modal.boxStyle))
end

function UI:resizeModal()
	local modalWidth = settings.theme.modal.widthFactor * self.width
	local modalHeight = self.modal:getMinimumHeight(modalWidth)
	self.modal:resize(modalWidth,modalHeight)
	
	local x = math.floor((self.width-modalWidth)/2)
	local y = math.floor((self.height-modalHeight)/2)
	self.modal:move(x,y)
end

function UI:removeModal()
	self.main:setBlock(false)
	self:removeChild(self.modal)
	self.modal = nil
end


-- Preset modals


function UI:displayMessage(text)
	local ui = LIST:new(settings.theme.modal.listStyle)
	ui:addTextEntry(text)
	ui:addButtonEntry("Dismiss", function() self:removeModal() end)
	self:setModal(ui)
end


function UI:resized(w,h)
	self.main:resize(w,h)
	if self.modal then
		self:resizeModal()
	end
end

return UI
