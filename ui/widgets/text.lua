---@class TextStyle
---@field horAlign "left"|"center"|"right"
---@field verAlign "bottom"|"center"|"top"
---@field color number[]

---@class TextUI : BaseNodeUI
---@field super BaseNodeUI
---@field new fun(self: Object, text: string, indention?: number, style: TextStyle): TextUI
local UI = Class("TextUI",require("ui.base.node"))

--halign valid values: left center right
--valign valid values: bottom center top
function UI:initialize(text,indention,style)
	UI.super.initialize(self)
	self.font = love.graphics.getFont()
	self.text = text
	self.indention = indention or 0
	self:setStyle(style)
	self.offsetY = 0
end

---@param style TextStyle
function UI:setStyle(style)
	if not style then
		error("No style specified!",2)
	end
	if style.horAlign then
		local ha = style.horAlign
		if not (ha=="left" or ha=="center" or ha=="right") then
			error(string.format("Horizontal alignment %q invalid!",ha),2)
		end
	else
		error("Horizontal alignment not specified!",2)
	end
	if style.verAlign then
		local va = style.verAlign
		if not (va=="bottom" or va=="center" or va=="top") then
			error(string.format("Vertical alignment %q invalid!",va),2)
		end
	else
		error("Vertical alignment not specified!",2)
	end
	if not style.color then
		error("Color not specified!",2)
	end
	self.style = style
	self:updateOffset()
end

function UI:setText(text)
	self.text = text
	self:updateOffset()
end

function UI:updateOffset()
	if self.style.verAlign=="center" then
		self.offsetY = math.floor( (self.height - self:getMinimumHeight(self.width))/2 +0.5 )
	elseif self.style.verAlign=="bottom" then
		self.offsetY = self.height - self:getMinimumHeight(self.width)
	end
	--only (valid) other option: top
	--leave offset at 0
end

function UI:getMinimumHeight(width)
	local _w, text = self.font:getWrap(self.text, width-self.indention)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h
end

function UI:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(self.style.color)
	love.graphics.printf(self.text, self.indention, self.offsetY, self.width-self.indention, self.style.horAlign)
end

function UI:resized(_width,_height)
	self:updateOffset()
end

return UI
