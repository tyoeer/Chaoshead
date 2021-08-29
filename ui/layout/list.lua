local TextEntry = require("ui.widgets.text")
local ButtonEntry = require("ui.widgets.button")

local UI = Class("ListUI",require("ui.base.container"))

function UI:initialize(entryMargin,indentSize)
	UI.super.initialize(self)
	
	self.entryMargin = entryMargin
	self.indentSize = indentSize
end

function UI:addTextEntry(text, indent, ...)
	self:addUIEntry(TextEntry:new(text, (indent or 0)*self.indentSize, ...))
end

function UI:addButtonEntry(...)
	local button = ButtonEntry:new(...)
	self:addUIEntry(button)
	--return the button so its border can possibly be set
	return button
end

function UI:addUIEntry(child)
	local width = self.width
	local height = child:getMinimumHeight(width)
	child:resize(width,height)
	local y = 0
	if #self.children>0 then
		local lastChild = self.children[#self.children]
		y = lastChild.y + lastChild.height + self.entryMargin
	end
	child:move(0,y)
	self:addChild(child)
end

function UI:resetList()
	--the garbage collector should take care of the old list
	self.children = {}
end

function UI:getMinimumHeight(width)
	width = width or self.width
	local out = 0
	for _,child in ipairs(self.children) do
		out = out + child:getMinimumHeight(width)
	end
	return out + self.entryMargin * (#self.children-1)
end

-- events

function UI:resized(w,h)
	local y = 0
	for _,child in ipairs(self.children) do
		child:move(0,y)
		local width = w
		local height = child:getMinimumHeight(width)
		child:resize(width,height)
		y = y + child.height + self.entryMargin
	end
end


return UI
