local BaseUI = require("ui.structure.base")
local Pool = require("libs.tyoeerUtils.entitypool")
local TextEntry = require("ui.list.text")
local ButtonEntry = require("ui.list.button")

local UI = Class("ListUI",BaseUI)

function UI:initialize()
	self.children = Pool:new()
	self.nChildren = 0
	
	self.entryMargin = 5
	self.indentSize = 15
	
	UI.super.initialize(self)
	self.title = "List"
end

function UI:addTextEntry(text,indent)
	self:addUIEntry(TextEntry:new(text, (indent or 0)*self.indentSize ))
end

function UI:addButtonEntry(...)
	self:addUIEntry(ButtonEntry:new(...))
end

function UI:addUIEntry(c)
	c.parent = self
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

function UI:getPropagatedMouseY(target)
	local offset = 0
	for c in self.children:iterate() do
		if c == target then
			return self:getMouseY() - offset
		end
		offset = offset + c.height + self.entryMargin
	end
end

-- events

local relayAll = function(index)
	UI[index] = function(self, ...)
		for c in self.children:iterate() do
			c[index](c, ...)
		end
	end
end


relayAll("update")

function UI:draw()
	love.graphics.push("all")
		for c in self.children:iterate() do
			c:draw()
			love.graphics.translate(0, c.height + self.entryMargin)
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

local function relayInput(index)
	UI[index] = function(self, name,group, isCursorBound)
		if isCursorBound then
			local y = self:getMouseY()
			local checkY = 0
			for c in self.children:iterate() do
				checkY = checkY + c.height
				if y <= checkY then
					c[index](c, name,group, isCursorBound)
					break
				end
				checkY = checkY + self.entryMargin
				if y < checkY then
					break
				end
			end
		else
			for c in self.children:iterate() do
				c[index](c, name,group, isCursorBound)
			end
		end
	end
end
relayInput("inputActivated")
relayInput("inputDeactivated")

relayAll("textInput")

function UI:mouseMoved(x,y, ...)
	local checkY = 0
	for c in self.children:iterate() do
		checkY = checkY + c.height
		if y <= checkY then
				c:mouseMoved(x, y - checkY + c.height, ...)
			break
		end
		checkY = checkY + self.entryMargin
		if y < checkY then
			break
		end
	end
end
function UI:wheelMoved(...)
	local x,y = self:getMousePos()
	local checkY = 0
	for c in self.children:iterate() do
		checkY = checkY + c.height
		if y <= checkY then
				c:wheelMoved(...)
			break
		end
		checkY = checkY + self.entryMargin
		if y < checkY then
			break
		end
	end
end

return UI
