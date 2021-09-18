local TextEntry = require("ui.widgets.text")
local ButtonEntry = require("ui.widgets.button")

local UI = Class("ListUI",require("ui.base.container"))

function UI:initialize(style)
	UI.super.initialize(self)
	
	if not style.entryMargin then
		error("Entry margin not specified!",2)
	end
	if not style.textIndentSize then
		error("Text indent size not specified!",2)
	end
	--style.textStyle is optional
	--style.buttonStyle is optional
	if style.buttonStyle and not style.textStyle then
		style.textStyle = style.buttonStyle.normal.textStyle
	end
	--style.defaulButtonPadding is allowed to be nil
	self.style = style
end

function UI:addTextEntry(text, indent, style)
	style = style or self.style.defaultTextStyle
	self:addUIEntry(TextEntry:new(text, (indent or 0)*self.style.textIndentSize, style))
end

function UI:addButtonEntry(contents, onClick, style, triggerOnActivate)
	style = style or self.style.buttonStyle
	local button = ButtonEntry:new(contents,onClick,style,triggerOnActivate)
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
		y = lastChild.y + lastChild.height + self.style.entryMargin
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
	return out + self.style.entryMargin * (#self.children-1)
end

-- events

function UI:resized(w,h)
	local y = 0
	for _,child in ipairs(self.children) do
		child:move(0,y)
		local width = w
		local height = child:getMinimumHeight(width)
		child:resize(width,height)
		y = y + child.height + self.style.entryMargin
	end
end


return UI
