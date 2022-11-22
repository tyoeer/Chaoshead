local LIST = require("ui.layout.list")
local BOX = require("ui.layout.box")
local BLOCK = require("ui.layout.block")

local UI = Class("ModalManagerUI",require("ui.base.container"))

local theme = Settings.theme.modal

function UI:initialize(child)
	UI.super.initialize(self)
	--self.modal
	--self.cancelAction
	--self.oldCursor
	--self.oldMouseX
	--self.oldMouseY
	self.stack = {}
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

function UI:setModal(ui, cancelAction, box)
	if box==nil then
		box = true
	end
	if box then
		ui = BOX:new(ui, theme.boxStyle)
	end
	
	if self.modal then
		table.insert(self.stack, {
			modal = self.modal,
			cancelAction = self.cancelAction,
			cursor = love.mouse.getCursor(),
			mouseX = self:getMouseX(),
			mouseY = self:getMouseY(),
		})
		self:removeModalRaw()
	else
		self.oldCursor = love.mouse.getCursor()
		self.oldMouseX = self:getMouseX()
		self.oldMouseY = self:getMouseY()
		love.mouse.setCursor()
	end
	
	self.cancelAction = cancelAction
	self:setModalRaw(ui)
end

function UI:resizeModal()
	local modalWidth = math.ceil(theme.widthFactor * self.width)
	self.modal:resize(modalWidth, self.height)
	
	local x = math.floor((self.width-modalWidth)/2)
	self.modal:move(x,0)
end

function UI:removeModalRaw()
	self.main:setBlock(false)
	self:removeChild(self.modal)
	self.cancelAction = nil
	self.modal = nil
end

function UI:removeModal()
	self:removeModalRaw()
	if #self.stack > 0 then
		local old = table.remove(self.stack)
		self:setModal(old.modal, old.cancelAction, false)
		love.mouse.setCursor(old.cursor)
	else
		love.mouse.setCursor(self.oldCursor)
	end
	self:mouseMoved(
		self:getMouseX(),
		self:getMouseY(),
		self:getMouseX()-self.oldMouseX,
		self:getMouseY()-self.oldMouseY
	)
end

-- actions

function UI:setCancelAction(cancelAction)
	self.cancelAction = cancelAction
end

-- Preset modals

function UI:displayMessage(...)
	local ui = LIST:new(theme.listStyle)
	for _,item in ipairs({...}) do
		if type(item)=="table" then
			if item.class then
				ui:addUIEntry(item)
			elseif type(item[1])=="string" and type(item[2])=="function" then
				ui:addButtonEntry(item[1], item[2])
			end
		else
			ui:addTextEntry(tostring(item))
		end
	end
	local dismiss = function() self:removeModal() end
	ui:addButtonEntry("Dismiss", dismiss)
	self:setModal(ui, dismiss)
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
