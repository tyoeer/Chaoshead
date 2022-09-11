local BlockRoot = require("ui.layout.blockRoot")

local UI = Class("BlockUI",require("ui.base.proxy"))

-- thsi UI can optionally block access to the underlying child

function UI:initialize(child,style)
	UI.super.initialize(self,child)
	
	if not style.overlayColor then
		error("Overlay color not set!",2)
	end
	self.style = style
	
	--self.child can get cleared
	self.contents = child
	self.blocking = false
	self.blockRoot = BlockRoot:new()
end

function UI:setBlock(block)
	--change nothing if we're already doing the right thing
	if self.blocking==block then return end
	self.blocking = block
	if block then
		--prevent potential double resizes where the contents first resize to blockRoot initial size, then back to their proper one
		-- cant use blockRoot:resize() first because it expects to have a child
		self.blockRoot.width = self.width
		self.blockRoot.height = self.height
		--self:removeChild(self.child) not neccesary, it gets removed automatically
		self.blockRoot:setChild(self.contents)
		--make sure the child keeps the right size
		self.blockRoot:resize(self.width,self.height)
	else
		--self.blockRoot:unsetChild() not neccesary, it gets unset automatically
		self:setChild(self.contents)
	end
end

function UI:onDraw()
	if self.blocking then
		self:drawChild(self.blockRoot)
		--print(self.contents.x, self.contents.y, self.contents.width, self.contents.height)
		love.graphics.setColor(self.style.overlayColor)
		love.graphics.rectangle("fill", 0,0, self.width,self.height)
	end
end

function UI:resized(w,h)
	--resize the one with the actual child
	--(the other would error because it has a nil child)
	if self.child then
		--resize the child
		UI.super.resized(self, w,h)
	else
		self.blockRoot:resize(w,h)
	end
end

return UI
