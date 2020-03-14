local BaseUI = require("ui.base")
local Pool = require("utils.entitypool")

--LevelBytesUI
local UI = Class(BaseUI)
--in case it ever changes, and this feels better
local Super = UI.super

function UI:initialize(w,h)
	self.children = Pool:new()
	self.nChildren = 0
	self.tabHeight = 30
	self.tabWidth = w
	Super.initialize(self,w,h)
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

function UI:resize(w,h)
	self.width = w
	self.height = h
	for child in self.children:iterate() do
		child:resize(w,h-self.tabHeight)
	end
end

function UI:draw()
	--draw activeChild
	love.graphics.push("all")
		love.graphics.translate(0, self.tabHeight)
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
		love.graphics.printf(child.title,x,y, self.tabWidth,"center")
		i = i + 1
	end
end

function UI:getMouseY(child)
	return Super.getMouseY(self)+(child and self.tabHeight or 0)
end

function UI:mousepressed(x,y,button,isTouch)
	local i = 1
	for child in self.children:iterate() do
		local xx = (i-1)*self.tabWidth
		if math.isPointInRectangle(
			x,y,
			xx, 0,
			xx+self.tabWidth, self.tabHeight
		) then
			self.activeChild = child
			return
		end
		i = i + 1
	end
	self.activeChild:mousepressed(x,y-self.tabHeight,buttton,isTouch)
end

function UI:keypressed(...)
	self.activeChild:keypressed(...)
end

function UI:mousemoved(...)
	self.activeChild:mousemoved(...)
end

function UI:wheelmoved(...)
	self.activeChild:wheelmoved(...)
end

return UI
