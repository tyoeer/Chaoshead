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

function UI:addUIEntry(ui)
	local e = {
		type = "ui",
		ui = ui,
		height = ui:getMinHeight()
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
				c.ui[index](c, ...)
			end
		end
	end
end

local relayMouse = function(index)
	UI[index] = function(self, x,y, ...)
		if y <= self.padding then break end
		local checkY = self.padding
		for c in self.children:iterate() do
			checkY = checkY + c.height
			if y <= checkY then
				if c.type=="ui" then
					c.ui[index](c.ui, x,y, ...)
				end
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
			if c.type=="text" then
				love.graphics.print(c.text,0,0)
			elseif c.type=="ui" then
				c.ui:draw()
			end
			love.graphics.translate(0, c.height)
		end
	love.graphics.pop("all")
end

relayAll("focus")
relayAll("visible")

function UI:resize(w,h)
	self.width = w
	self.height = h
	
	for child in self.children:iterate() do
		if child.type=="ui" then
			child.ui:resize(w - 2*self.padding, child.ui.height)
		end
	end
end

relayAll("keypressed")
relayAll("textinput")

relayMosue("mousepressed")
relayMouse("mousereleased")
relayMouse("mousemoved")
UI:wheelmoved() = function(self, ...)
	local x,y = self:getMousePos()
	if y <= self.padding then break end
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
