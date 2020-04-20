local UI = Class(require("ui.list"))

function UI:initialize(w,h)
	UI.super.initialize(self,w,h)
	self.title = "Level Info"
end

function UI:reload()
	self:resetList()
	if level then
		self:addTextEntry("Width:  "..level.width)
		self:addTextEntry("Height: "..level.height)
	else
		self:addTextEntry("No level loaded :(")
	end
end

return UI
