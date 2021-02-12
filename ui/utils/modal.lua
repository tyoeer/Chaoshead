local UI = Class(require("ui.structure.padding"))

function UI:initialize(child)
	UI.super.initialize(self,child,10)
	self.title = child.title
	--self.bg
end



function UI:draw()
	love.graphics.setColor(settings.col.modal.border)
	love.graphics.rectangle(
		"line",
		self.paddingLeft-0.5, self.paddingUp-0.5,
		self.child.width+1, self.child.height+1
	)
	love.graphics.setColor(settings.col.modal.bg)
	love.graphics.rectangle(
		"fill",
		self.paddingLeft, self.paddingUp,
		self.child.width, self.child.height
	)
	UI.super.draw(self)
end

function UI:resize(w,h)
	local modalWidth = settings.dim.modal.widthFactor * w
	self.paddingLeft = math.floor((w-modalWidth)/2)
	self.paddingRight = self.paddingLeft
	
	local modalHeight = self.child:getMinimumHeight(modalWidth)
	self.paddingUp = math.floor((h-modalHeight)/2)
	self.paddingDown = self.paddingUp
	
	UI.super.resize(self, w,h)
end

return UI
