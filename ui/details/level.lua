local UI = Class(require("ui.base"))

function UI:initialize(w,h,level)
	self.level = level
	self.class.super.initialize(self,w,h)
	self.title = "Level Info"
end

function UI:setLevel(level)
	self.level = level
end

function UI:draw()
	love.graphics.setColor(1,1,1,1)
	if self.level then
		love.graphics.print("Width:",10,10)
		love.graphics.print(self.level.width,60,10)
		love.graphics.print("Height:",10,30)
		love.graphics.print(self.level.height,60,30)
	else
		love.graphics.print("No level loaded :(",10,10)
	end
end

return UI
