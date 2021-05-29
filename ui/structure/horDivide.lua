local BaseUI = require("ui.structure.base")
--local Pool = require("utils.entitypool")

local UI = Class("HorDivideUI",BaseUI)

--[[
When there's an apparent off by one error, test it first.
Current off by ones have been deduced by pixel-perfect mouse pointer placement testing.
]]--

function UI:initialize(left,right)
	self.leftChild = left
	left.parent = self
	
	self.rightChild = right
	right.parent = self
	
	self.divisionRatio = 0.25
	--self.divisionX = -1
	self.divisionWidth = 1 -1
	UI.super.initialize(self)
	self.title = "Divide"
end

function UI:setLeftChild(ui)
	self.leftChild.parent = nil
	self.leftChild = ui
	ui.parent = self
	self:setDivisionX(self.divisionX)
end

function UI:setRightChild(ui)
	self.rightChild.parent = nil
	self.rightChild = ui
	ui.parent = self
	self:setDivisionX(self.divisionX)
end

function UI:setDivisionRatio(ratio)
	self.divisionRatio = ratio
	self.divisionX = math.round(self.width * ratio)
	
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
		error("Illegal child tried to get mouse X: "..tostring(child).."\nCurrent children: "..tostring(self.leftChild).." - "..tostring(self.rightChild))
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
	love.graphics.setColor(settings.col.horDivide)
	love.graphics.line(
		self.divisionX, 0,
		self.divisionX, self.height
	)
	love.graphics.line(
		self.divisionX + self.divisionWidth, 0,
		self.divisionX + self.divisionWidth, self.height
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

local relayInput = function(index)
	UI[index] = function(self, name, group, isCursorBound)
		if isCursorBound then
			local x = self:getMouseX()
			if x < self.leftChild.width then
				self.leftChild[index](self.leftChild, name,group,isCursorBound)
			elseif x >= self.divisionX + self.divisionWidth - 1 then
				self.rightChild[index](self.rightChild, name,group,isCursorBound)
			end
		else
			self.leftChild[index](self.leftChild, name,group,isCursorBound)
			self.rightChild[index](self.rightChild, name,group,isCursorBound)
		end
	end
end
relayInput("inputActivated")
relayInput("inputDeactivated")

relayBoth("textInput")

function UI:mouseMoved(x,y, dx,dy, isTouch)
	if x < self.leftChild.width then
		self.leftChild:mouseMoved(x,y, dx,dy, isTouch)
	elseif x >= self.divisionX + self.divisionWidth - 1 then
		self.rightChild:mouseMoved(x - self.divisionX - self.divisionWidth, y, dx,dy, isTouch)
	end
end
function UI:wheelMoved(x,y)
	local xx = self:getMouseX()
	if xx < self.leftChild.width then
		self.leftChild:wheelMoved(x, y)
	elseif xx >= self.divisionX + self.divisionWidth - 1 then
		self.rightChild:wheelMoved(x, y)
	end
end


return UI
