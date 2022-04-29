local TextInput = require("ui.widgets.textInput")
local Text = require("ui.widgets.text")
local List = require("ui.layout.list")

local UI = Class("ParsedInputUI",require("ui.base.proxy"))

function UI:initialize(parser, style)
	self.style = style
	UI.super.initialize(self, List:new(style.listStyle))
	if not parser then
		error("No parser specified!",2)
	elseif type(parser) ~= "function" then
		error("Parser not a function, it's a "..type(parser),2)
	end
	self.parser = parser
	self.input = TextInput:new(function() self:contentsChanged() end, style.inputStyle)
	--self.errorMessage
	--self.parsed
	self.child:addUIEntry(self.input)
end

function UI:hideError()
	if self.errorMessage then
		self.errorMessage = nil
		self.child:resetList()
		self.child:addUIEntry(self.input)
	end
end

function UI:showError(mes)
	if not self.errorMessage then
		for k,v in pairs(self.style) do
			print(k,v)
		end
		self.errorMessage = Text:new(mes, 0, self.style.errorStyle)
		self.child:addUIEntry(self.errorMessage)
	end
	self.errorMessage:setText(mes)
end

function UI:getParsed()
	return self.parsed
end

function UI:getMinimumHeight(w)
	return self.child:getMinimumHeight(w)
end

function UI:contentsChanged()
	local val, err = self.parser(self.input:getText())
	self.parsed = val
	if val then
		self:hideError()
	else
		self:showError(err or "Invalid input given")
	end
end

return UI