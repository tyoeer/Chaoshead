local BaseUI = require("ui.base")
--local Pool = require("utils.entitypool")

local UI = Class(BaseUI)

--[[
When there's an apparent off by one error, test it first.
Current off by ones have been deduced by pixel-perfect mouse pointer placement testing.
]]--

function UI:initialize(w,h, left,right)
	self.leftChild = left
	left.parent = self
	self.rightChild = right
	right.parent = self
	self.divisionRatio = 0.3
	--self.divisionX = -1
	self.divisionWidth = 1
	self.class.super.initialize(self,w,h)
	self.title = "Divide"
end

function UI:setDivisionRatio(ratio)
	self.divisionRatio = ratio
	self.divisionX = self.width * ratio
	
	self.leftChild:resize(self.divisionX-1, self.height)
	self.rightChild:resize(self.width - self.divisionX - self.divisionWidth, self.height)
end
function UI:setDivisionX(x)
	self.divisionX = x
	self.divisionRatio = x/self.width
	
	self.leftChild:resize(self.divisionX-1, self.height)
	self.rightChild:resize(self.width - self.divisionX - self.divisionWidth, self.height)
end

function UI:getPropagatedMouseX(child)
	if child == self.leftChild then
		return self:getMouseX()
	elseif child == self.rightChild then
		return self:getMouseX() - self.divisionX - self.divisionWidth
	else
		error("Illegal child tried to get mouse X: "..tostring(child))
	end
end

-- events

local relayBoth = function(index)
	UI[index] = function(self, ...)
		self.leftChild[index](self.leftChild, ...)
		self.rightChild[index](self.rightChild, ...)
	end
end

relayBoth("update")

function UI:draw()
	--draw leftChild
	love.graphics.push("all")
		local x,y = love.graphics.transformPoint(0,0)
		local endX,endY = love.graphics.transformPoint(self.divisionX, self.leftChild.height)
		love.graphics.intersectScissor(x, y, endX-x, endY-y)
		self.leftChild:draw()
	love.graphics.pop("all")
	
	--draw rightChild
	love.graphics.push("all")
		love.graphics.translate(self.divisionX + self.divisionWidth,0)
		local x,y = love.graphics.transformPoint(0,0)
		local endX,endY = love.graphics.transformPoint(self.rightChild.width, self.rightChild.height)
		love.graphics.intersectScissor(x, y, endX-x, endY-y)
		self.rightChild:draw()
	love.graphics.pop("all")
	
	--draw divider
	love.graphics.setColor(1,1,1,1)
	love.graphics.line(
		self.divisionX, 0,
		self.divisionX, self.height
	)
	love.graphics.line(
		self.divisionX + self.divisionWidth-1, 0,
		self.divisionX + self.divisionWidth-1, self.height
	)
end

relayBoth("focus")
relayBoth("visible")
function UI:resize(w,h)
	self.width = w
	self.height = h
	
	--reset divisionX and child sizes
	self:setDivisionRatio(self.divisionRatio)
end

relayBoth("keypressed")
relayBoth("textinput")

local relayMouse = function(index)
	UI[index] = function(self, x, ...)
		if x < self.leftChild.width then
			self.leftChild[index](self.leftChild, x, ...)
		elseif x >= self.divisionX + self.divisionWidth - 1 then
			self.rightChild[index](self.rightChild, x, ...)
		end
	end
end

relayMouse("mousepressed")
relayMouse("mousereleased")
relayMouse("mousemoved")
function UI:wheelmoved(x,y)
	local xx = self:getMouseX()
	if xx < self.leftChild.width then
		self.leftChild:wheelmoved(x, y)
	elseif xx >= self.divisionX + self.divisionWidth - 1 then
		self.rightChild:wheelmoved(x, y)
	end
end


return UI
