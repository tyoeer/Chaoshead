local UI = Class("BoxUI",require("ui.layout.padding"))

function UI:initialize(child)
	UI.super.initialize(self, child, settings.dim.misc.boxPadding)
end

function UI:preDraw()
	love.graphics.setColor(settings.col.box.bg)
	love.graphics.rectangle(
		"fill",
		0, 0,
		self.width, self.height
	)
	love.graphics.setColor(settings.col.box.border)
	love.graphics.rectangle(
		"line",
		0.5, 0.5,
		self.width-1, self.height-1
	)
end

return UI
