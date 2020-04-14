local BaseUI = require("ui.base")
local Pool = require("utils.entitypool")
local TextEntry = require("ui.list.text")

local UI = Class("ListUI",BaseUI)

function UI:initialize(w,h)
	self.children = Pool:new()
	self.nChildren = 0
	
	self.padding = 10
	self.textEntryHeight = 20
	
	UI.super.initialize(self,w,h)
	self.title = "List"
end

function UI:addTextEntry(text)
	self:addUIEntry(TextEntry:new(-1,-1,text,5))
end

function UI:addUIEntry(c)
	c.parent = this
	local w = self.width - 2 * self.padding
	local h = c:getMinimumHeight(w)
	c:resize(w,h)
	self.children:add(c)
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
			c[index](c, ...)
		end
	end
end

local relayMouse = function(index)
	UI[index] = function(self, x,y, ...)
		if y <= self.padding then return end
		local checkY = self.padding
		for c in self.children:iterate() do
			checkY = checkY + c.height
			if y <= checkY then
					c[index](c, x,y, ...)
				break
			end
		end
	end
end


relayAll("update")

function UI:draw()
	love.graphics.push("all")
		love.graphics.translate(self.padding, self.padding)
		for c in self.children:iterate() do
			c:draw()
			love.graphics.translate(0, c.height)
		end
	love.graphics.pop("all")
end

relayAll("focus")
relayAll("visible")

function UI:resize(w,h)
	self.width = w
	self.height = h
	
	for c in self.children:iterate() do
		local w = self.width - 2 * self.padding
		local h = c:getMinimumHeight(w)
		c:resize(w,h)
	end
end

relayAll("keypressed")
relayAll("textinput")

relayMouse("mousepressed")
relayMouse("mousereleased")
relayMouse("mousemoved")
function UI:wheelmoved(self, ...)
	local x,y = self:getMousePos()
	if y <= self.padding then return end
	local checkY = self.padding
	for c in self.children:iterate() do
		checkY = checkY + c.height
		if y <= checkY then
			if c.type=="ui" then
				c.ui:wheelmoved(...)
			end
			break
		end
	end
end

return UI
