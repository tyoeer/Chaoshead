local BaseUI = require("ui.base")
local Pool = require("utils.entitypool")

local UI = Class(BaseUI)

function UI:initialize(w,h)
	self.children = Pool:new()
	self.nChildren = 0
	self.tabHeight = 30
	self.tabWidth = w
	UI.super.initialize(self,w,h)
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

relay("keypressed")
relay("textinput")

function UI:mousepressed(x,y,button,isTouch)
	if y <= self.tabHeight then
		local i = 1
		for child in self.children:iterate() do
			local xx = (i-1)*self.tabWidth
			if x >= xx and x < xx+self.tabWidth then
				self.activeChild = child
				return
			end
			i = i + 1
		end
	else
		self.activeChild:mousepressed(x,y-self.tabHeight,buttton,isTouch)
	end
end
relay("mousereleased")
relay("mousemoved")
relay("wheelmoved")


return UI
