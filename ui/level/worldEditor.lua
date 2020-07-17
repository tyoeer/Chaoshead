local UI = Class(require("ui.structure.base"))


function UI:initialize(editor)
	self.editor = editor
	self.level = editor.level
	--camera stuff
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	self.zoomSpeed = math.sqrt(2)
	--state stuff
	self.selecting = false
	
	--UI stuff
	UI.super.initialize(self)
	self.title = "World Editor"
end

function UI:reload(level)
	self.level = level
end

function UI:getMouseTile(x,y)
	x = self:toWorldX(x or self:getMouseX())
	y = self:toWorldY(y or self:getMouseY())
	return math.ceil(x/TILE_SIZE), math.ceil(y/TILE_SIZE)
end

function UI:toWorldX(x)
	x = x - self.width/2
	x = x / self.zoomFactor
	x = x - self.x
	return x
end
function UI:toWorldY(y)
	y = y - self.height/2
	y = y / self.zoomFactor
	y = y - self.y
	return y
end


function UI:draw()
	love.graphics.push()
	--camera
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.x, self.y)
		--bg
		love.graphics.setColor(0,0.5,1,1)
		love.graphics.rectangle(
			"fill",
			0, 0,
			self.level.width*TILE_SIZE, self.level.height*TILE_SIZE
		)
		--objects
		local startX, startY = self:toWorldX(0), self:toWorldY(0)
		local endX, endY = self:toWorldX(self.width), self:toWorldY(self.height)
		startX, startY = math.ceil(startX/TILE_SIZE), math.ceil(startY/TILE_SIZE)
		endX, endY = math.ceil(endX/TILE_SIZE), math.ceil(endY/TILE_SIZE)
		for x = startX, endX, 1 do
			for y = startY, endY, 1 do
				local obj = self.level.foreground:get(x,y)
				if obj then obj:draw() end
			end
		end
		--hover
		local x,y = self:getMouseTile()
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.rectangle(
			"fill",
			(x-1)*TILE_SIZE, (y-1)*TILE_SIZE,
			TILE_SIZE, TILE_SIZE
		)
	love.graphics.pop()
end

function UI:mousemoved(x,y,dx,dy)
	if input.isActive("drag","camera") then
		self.selecting = false
		self.x = self.x + dx/self.zoomFactor
		self.y = self.y + dy/self.zoomFactor
	end
end

function UI:inputActivated(name,group, isCursorBound)
	if name=="select" and group=="editor" then
		self.selecting = true
	end
end

function UI:inputDeactivated(name,group, isCursorBound)
	if name=="select" and group=="editor" then
		if self.selecting then
			self.selecting = false
			self.editor:selectObject(self:getMouseTile(x,y))
		end
	end
end

function UI:wheelmoved(x,y)
	if y>0 then
		self.zoomFactor = self.zoomFactor * self.zoomSpeed
	elseif y<0 then
		self.zoomFactor = self.zoomFactor / self.zoomSpeed
	end
	self.x = math.roundPrecision(self.x,self.zoomFactor)
	self.y = math.roundPrecision(self.y,self.zoomFactor)
end

return UI
