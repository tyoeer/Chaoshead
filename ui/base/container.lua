local UI = Class("ContainerUI",require("ui.base.node"))

function UI:initialize()
	UI.super.initialize(self)
	self.children = {}
end

function UI:addChild(child)
	table.insert(self.children,child)
	child.parent = self
end

function UI:removeChild(toRemove)
	for i,child in ipairs(self.children) do
		if child==toRemove then
			table.remove(self.children,i)
			child.parent = nil
			break
		end
	end
end

function UI:findChildAt(x,y)
	for _,child in ipairs(self.children) do
		if x >= child.x and y >= child.y and x < child.x+child.width and y < child.y+child.height then
			return child
		end
	end
end

--events
local function rAll(event)
	local hook = "on"..event:sub(1,1):upper()..event:sub(2,-1)
	UI[event] = function(self,...)
		if not self[hook](self,...) then
			for _,child in ipairs(self.children) do
				child[event](child,...)
			end
		end
	end
	--stub the hook
	UI[hook] = function() end
end

--the resized event should be propagated by resizing children, not automatically
--in most cases children should be a different size than their parent
--rAll("resized")

rAll("update")
function UI:draw()
	if not self:onDraw() then
		for _,child in ipairs(self.children) do
			love.graphics.push("all")
				love.graphics.translate(child.x, child.y)
				--find childs bounding box in screen coordinates
				local startX,startY = love.graphics.transformPoint(0,0)
				local endX,endY = love.graphics.transformPoint(child.width, child.height)
				--make sure the child can't draw outside it's bounding box
				love.graphics.intersectScissor(startX, startY, endX-startX, endY-startY)
				child:draw()
			love.graphics.pop("all")
		end
	end
end
function UI:onDraw() end

rAll("focus")
rAll("visible")

function UI:inputActivated(name,group, isCursorBound)
	if not self:onInputActivated(name,group, isCursorBound) then
		if isCursorBound then
			local child = self:findChildAt(self:getMousePos())
			if child then
				child:inputActivated(name,group, isCursorBound)
			end
		else
			for _,child in ipairs(self.children) do
				child:inputActivated(name,group, isCursorBound)
			end
		end
	end
end
function UI:onInputActivated() end
function UI:inputDeactivated(name,group, isCursorBound)
	if not self:onInputDeactivated(name,group, isCursorBound) then
		if isCursorBound then
			local child = self:findChildAt(self:getMousePos())
			if child then
				child:inputDeactivated(name,group, isCursorBound)
			end
		else
			for _,child in ipairs(self.children) do
				child:inputDeactivated(name,group, isCursorBound)
			end
		end
	end
end
function UI:onInputDeactivated() end

rAll("textInput")

function UI:mouseMoved(x,y, dx,dy)
	if not self:onMouseMoved(x,y, dx,dy) then
		--also give the event to the child the mouse moved out from
		local oldChild = self:findChildAt(x-dx, y-dy)
		if oldChild then
			oldChild:mouseMoved(x-oldChild.x, y-oldChild.y, dx,dy)
		end
		local newChild = self:findChildAt(x,y)
		if newChild and newchild ~= oldChild then
			newChild:mouseMoved(x-newChild.x, y-newChild.y, dx,dy)
		end
	end
end
function UI:onMouseMoved() end
function UI:wheelMoved(dx,dy)
	if not self:onWheelMoved(dx,dy) then
		local child = self:findChildAt(self:getMousePos())
		if child then
			child:wheelMoved(dx,dy)
		end
	end
end
function UI:onWheelMoved() end

return UI
