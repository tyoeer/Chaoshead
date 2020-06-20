local BaseUI = require("ui.structure.base")
local Pool = require("utils.entitypool")

local UI = Class("TabsUI",BaseUI)

function UI:initialize()
	self.children = Pool:new()
	self.nChildren = 0
	self.tabHeight = 30
	self.tabWidth = w
	UI.super.initialize(self)
	self.title = "Tabs"
end

function UI:addChild(child)
	self.children:add(child)
	self.nChildren = self.nChildren + 1
	self.tabWidth = math.floor(self.width/self.nChildren)
	child.parent = self
	child:resize(self.width,self.height-self.tabHeight)
	if not self.activeChild then
		self.activeChild = child
	end
end

function UI:setActive(child)
	self.activeChild:focus(false)
	self.activeChild = child
	child:focus(true)
end

function UI:removeChild(child)
	if self.children:remove(child) then
		self.nChildren = self.nChildren - 1
		self.tabWidth = math.floor(self.width/self.nChildren)
		if child == self.activeChild then
			self.activeChild = self.children:getBottom()
		end
	end
end

function UI:getPropagatedMouseY(child)
	return self:getMouseY() - self.tabHeight
end

-- events

local relay = function(index)
	UI[index] = function(self, ...)
		self.activeChild[index](self.activeChild, ...)
	end
end

relay("update")

function UI:draw()
	--draw activeChild
	love.graphics.push("all")
		love.graphics.translate(0, self.tabHeight+1)
		local x,y = love.graphics.transformPoint(0,0)
		local endX,endY = love.graphics.transformPoint(self.activeChild.width, self.activeChild.height)
		love.graphics.intersectScissor(x, y, endX-x, endY-y)
		self.activeChild:draw()
	love.graphics.pop("all")
	
	--draw ui
	love.graphics.setColor(1,1,1,1)
	love.graphics.line(0,self.tabHeight, self.width,self.tabHeight)
	local i = 1
	for child in self.children:iterate() do
		local x = (i-1)*self.tabWidth
		local y = math.round(self.tabHeight/4)
		if math.isPointInRectangle(
			self:getMouseX(), self:getMouseY(),
			x, 0,
			x+self.tabWidth, self.tabHeight
		) then
			love.graphics.setColor(1,1,1,0.5)
			love.graphics.rectangle(
				"fill",
				x,0,
				self.tabWidth, self.tabHeight
			)
		end
		love.graphics.setColor(1,1,1,1)
		love.graphics.printf(child.title,math.round(x),y, self.tabWidth,"center")
		i = i + 1
	end
end

relay("focus")
relay("visible")
function UI:resize(w,h)
	self.width = w
	self.height = h
	
	self.tabWidth = w / self.nChildren
	
	for child in self.children:iterate() do
		child:resize(w, h-self.tabHeight)
		child = self.activeChild
	end
end

function UI:inputActivated(name,group,isCursorBound)
	if isCursorBound then
		local y = self:getMouseY()
		if y <= self.tabHeight then
			if name=="click" and group=="main" then
				local i = 1
				local x = self:getMouseX()
				for child in self.children:iterate() do
					local xx = (i-1)*self.tabWidth
					if x >= xx and x < xx+self.tabWidth then
						self:setActive(child)
						return
					end
					i = i + 1
				end
			end
			return
		end
	end
	self.activeChild:inputActivated(name,group,isCursorBound)
end
function UI:inputDeactivated(name,group,isCursorBound)
	if isCursorBound then
		local y = self:getMouseY()
		if y > self.tabHeight then
			self.activeChild:inputDeactivated(name,group,isCursorBound)
		end
		return
	end
	self.activeChild:inputDeactivated(name,group,isCursorBound)
end

relay("textinput")

function UI:mousemoved(x,y, dx,dy, ...)
	if y > self.tabHeight or y-dy > self.tabHeight then
		self.activeChild:mousemoved(x,y - self.tabHeight, dx,dy, ...)
	end
end
function UI:wheelmoved(x,y)
	if self:getMouseY() > self.tabHeight then
		self.activeChild:wheelmoved(x,y)
	end
end


return UI
