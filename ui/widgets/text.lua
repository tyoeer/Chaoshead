local UI = Class("TextUI",require("ui.base.node"))

--halign valid values: left center right
--valign valid values: top center bottom
function UI:initialize(text,indention,halign,valign)
	UI.super.initialize(self)
	self.text = text
	self.indention = indention or 0
	self.halign = halign or "left"
	self.valign = valign or "top"
	self.offsetY = 0
	self.font = love.graphics.getFont()
end

function UI:getMinimumHeight(width)
	local w, text = self.font:getWrap(self.text, width-self.indention)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h
end

function UI:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(settings.col.list.text)
	love.graphics.printf(self.text, self.indention, self.offsetY, self.width-self.indention, self.halign)
end

function UI:resized(width,height)
	if self.valign=="center" then
		self.offsetY = math.floor( (self.height - self:getMinimumHeight(width))/2 +0.5 )
	elseif self.valign=="bottom" then
		self.offsetY = self.height - self:getMinimumHeight(width)
	end
	--only (valid) other option: top
	--leave offset at 0
end

return UI
