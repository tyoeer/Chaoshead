local BaseUI = require("ui.base")
local Pool = require("utils.entitypool")

local UI = Class("ListUI",BaseUI)

function UI:initialize(w,h)
	self.children = Pool:new()
	self.nChildren = 0
	
	self.padding = 10
	self.textEntryHeight = 20
	
	print(self.class.super)
	UI.super.initialize(self,w,h)
	self.title = "List"
end

function UI:addTextEntry(text)
	local e = {
		type = "text",
		text = text,
		height = self.textEntryHeight
	}
	self.children:add(e)
	self.nChildren = self.nChildren + 1
end

function UI:resetList()
	--the garbage collector should take care of the old pool
	self.children = Pool:new()
end

-- event propagation

function UI:getPropagatedMouseY(child)
	return self:getMouseY() - self.tabHeight
end

-- events

local relayAll = function(index)
	UI[index] = function(self, ...)
		for c in self.children:iterate() do
			if c.type=="ui" then
				c[index](c, ...)
			end
		end
	end
end

relayAll("update")

function UI:draw()
	love.graphics.push("all")
		love.graphics.translate(self.padding, self.padding)
		for c in self.children:iterate() do
			if c.type=="text" then
				love.graphics.print(c.text,0,0)
			end
			love.graphics.translate(0, c.height)
		end
	love.graphics.pop("all")
end

--[[
??relay("focus")
relayAll("visible")
function UI:resize(w,h)
	self.width = w
	self.height = h
	
	self.tabWidth = w / self.nChildren
	
	for child in self.children:iterate() do
		child:resize(w, h-self.tabHeight)
		child = self.activeChild
	end
end

??relay("keypressed")
??relay("textinput")

M?function UI:mousepressed(x,y,button,isTouch)
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
M?relay("mousereleased")
M?relay("mousemoved")
M?relay("wheelmoved")
]]--

return UI
