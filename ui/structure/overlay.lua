local UI = Class(require("ui.structure.proxy"))

function UI:initialize(child)
	UI.super.initialize(self,child)
	self.overlayColor = settings.col.modal.overlay
	self.title = child.title
	--self.bg
end

function UI:setOverlay(overlay)
	self.bg = self.child
	self:setChild(overlay)
	self.bg.parent = self
end

function UI:removeOverlay()
	self.child = self.bg
	self.bg = nil
end


function UI:getPropagatedMouseX(child)
	if self.bg and child~=self.child then
		--prevent bg from interacting with mouse
		--e.g. button hvoer effects
		return -1
	else
		return self:getMouseX()
	end
end
function UI:getPropagatedMouseY(child)
	if self.bg and child~=self.child then
		--prevent bg from interacting with mouse
		--e.g. button hvoer effects
		return -1
	else
		return self:getMouseY()
	end
end


function UI:draw()
	if self.bg then
		self.bg:draw()
		love.graphics.setColor(self.overlayColor)
		love.graphics.rectangle(
			"fill",
			0,0,
			self.width, self.height
		)
	end
	UI.super.draw(self)
end

function UI:resize(w,h)
	if self.bg then
		self.bg:resize(w,h)
	end
	UI.super.resize(self, w,h)
end

return UI
