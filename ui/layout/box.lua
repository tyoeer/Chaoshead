local UI = Class("BoxUI",require("ui.layout.padding"))

function UI:initialize(child,style)
	if not style.padding then
		error("Padding not specified!",2)
	end
	if not style.backgroundColor then
		error("Background color not specified!",2)
	end
	if not style.borderColor then
		error("Border color not specified!",2)
	end
	self.style = style
	UI.super.initialize(self, child, style.padding)
end

function UI:preDraw()
	love.graphics.setColor(self.style.backgroundColor)
	love.graphics.rectangle(
		"fill",
		0, 0,
		self.width, self.height
	)
	love.graphics.setColor(self.style.borderColor)
	love.graphics.rectangle(
		"line",
		0.5, 0.5,
		self.width-1, self.height-1
	)
end

return UI
