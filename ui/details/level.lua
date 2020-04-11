local UI = Class(require("ui.list"))

function UI:initialize(w,h,level)
	UI.super.initialize(self,w,h)
	self.title = "Level Info"
	self:setLevel(level)
end

function UI:setLevel(level)
	self.level = level
	self:reload()
end

function UI:reload()
	self:resetList()
	if self.level then
		self:addTextEntry("Width:  "..self.level.width)
		self:addTextEntry("Height: "..self.level.height)
	else
		self:addTextEntry("No level loaded :(")
	end
end

return UI
