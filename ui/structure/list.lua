local BaseUI = require("ui.base")
local Pool = require("utils.entitypool")
local TextEntry = require("ui.list.text")

local UI = Class("ListUI",BaseUI)

function UI:initialize()
	self.children = Pool:new()
	self.nChildren = 0
	
	self.textEntryVPadding = 5
	self.indentSize = 15
	
	UI.super.initialize(self)
	self.title = "List"
end

function UI:addTextEntry(text,indent)
	self:addUIEntry(TextEntry:new(text, self.textEntryVPadding, (indent or 0)*self.indentSize ))
end

function UI:addUIEntry(c)
	c.parent = this
	local w = self.width
	local h = c:getMinimumHeight(w)
	c:resize(w,h)
	self.children:add(c)
	self.nChildren = self.nChildren + 1
end

function UI:resetList()
	--the garbage collector should take care of the old pool
	self.children = Pool:new()
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
		local checkY = 0
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
		local w = self.width
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
	local checkY = 0
	for c in self.children:iterate() do
		checkY = checkY + c.height
		if y <= checkY then
				c:wheelmoved(...)
			break
		end
	end
end

return UI