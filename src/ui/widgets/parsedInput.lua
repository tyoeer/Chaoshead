local TextInput = require("ui.widgets.textInput")
local Text = require("ui.widgets.text")
local List = require("ui.layout.list")

---@alias ParseFunction fun(text: string): unknown?, string?

---@class ParsedInputStyle
---@field listStyle ListStyle
---@field inputStyle TextInputStyle
---@field errorStyle TextStyle

---@class ParsedInputUI : ProxyUI
---@field super ProxyUI
---@field new fun(self: self, parser: ParseFunction, style: ParsedInputStyle): self
local UI = Class("ParsedInputUI",require("ui.base.proxy"))

function UI:initialize(parser, style)
	self:setStyle(style)
	UI.super.initialize(self, List:new(self.style.listStyle))
	if not parser then
		error("No parser specified!",2)
	elseif type(parser) ~= "function" then
		error("Parser not a function, it's a "..type(parser),2)
	end
	self.parser = parser
	self.input = TextInput:new(function() self:contentsChanged() end, self.style.inputStyle)
	--self.errorMessage
	--self.parsed
	self.child:addUIEntry(self.input)
end

function UI:setStyle(style)
	if not style then
		error("No style specified!",2)
	end
	if not style.listStyle then
		error("List style not specified!",2)
	end
	if not style.inputStyle then
		error("Input style not specified!",2)
	end
	if not style.errorStyle then
		error("Error style not specified!",2)
	end
	self.style = style
end

function UI:hideError()
	if self.errorMessage then
		self.errorMessage = nil
		self.child:resetList()
		self.child:addUIEntry(self.input)
		self:minimumHeightChanged()
	end
end

function UI:showError(mes)
	if not self.errorMessage then
		self.errorMessage = Text:new(mes, 0, self.style.errorStyle)
		self.child:addUIEntry(self.errorMessage)
		self:minimumHeightChanged()
	end
	self.errorMessage:setText(mes)
end


function UI:grabFocus()
	self.input:grabFocus()
end

function UI:focusWithDefault(default)
	self.input:focusWithDefault(default)
end

function UI:setRaw(str)
	self.input:setText(str)
	self:contentsChanged()
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