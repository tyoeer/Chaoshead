---@class HorDivideUI : ContainerUI
---@field super ContainerUI
local UI = Class("HorDivideUI",require("ui.base.container"))

--[[
When there's an apparent off by one error, test it first.
Current off by ones have been deduced by pixel-perfect mouse pointer placement testing.
]]--

function UI:initialize(left,right,style)
	UI.super.initialize(self)
	self.style = style
	if not style.divisionRatio then
		error("Division ratio not set!",2)
	end
	if not style.dividerColor then
		error("Divider color not set!",2)
	end
	if not style.dividerWidth then
		error("Divider width not set!",2)
	end
	self.divisionX = math.huge
	
	self:setLeftChild(left)
	--self.leftChild
	self:setRightChild(right)
	--self.rightChild
end

function UI:setLeftChild(ui)
	self:removeChild(self.leftChild)
	self:addChild(ui)
	self.leftChild = ui
	--leftChild position doesn't change so only has to be set once
	ui:move(0,0)
	self:updateLeftChild()
end

function UI:setRightChild(ui)
	self:removeChild(self.rightChild)
	self:addChild(ui)
	self.rightChild = ui
	self:updateRightChild()
end

function UI:updateLeftChild()
	--if divisionX = 200, the div start at pixel 200
	--meaning leftCHild has the pixels 0-199
	--which in total are 200 = divisionX pixels
	self.leftChild:resize(self.divisionX, self.height)
end

function UI:updateRightChild()
	self.rightChild:move(self.divisionX + self.style.dividerWidth, 0)
	self.rightChild:resize(self.width - self.divisionX - self.style.dividerWidth, self.height)
end

function UI:updateChildren()
	self:updateLeftChild()
	self:updateRightChild()
end

function UI:setDivisionRatio(ratio)
	self.divisionRatio = ratio
	self.divisionX = math.round(self.width * ratio)
	self:updateChildren()
end
function UI:setDivisionX(x)
	self.divisionX = x
	self.divisionRatio = x/self.width
	self:updateChildren()
end

-- events

function UI:onDraw()
	--draw divider
	love.graphics.setColor(self.style.dividerColor)
	love.graphics.line(
		self.divisionX+0.5, 0,
		self.divisionX+0.5, self.height
	)
	love.graphics.line(
		self.divisionX + self.style.dividerWidth-0.5, 0,
		self.divisionX + self.style.dividerWidth-0.5, self.height
	)
end

function UI:resized(w,h)
	--reset divisionX and child sizes
	self:setDivisionRatio(self.style.divisionRatio)
end

return UI
