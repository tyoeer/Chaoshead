local UTILS = require("utils.levelUtils")

local UI = Class(require("ui.structure.base"))

function UI:initialize(editor)
	self.editor = editor
	self.level = editor.level
	--camera stuff
	self.cameraX = 0
	self.cameraY = 0
	self.zoomFactor = 1
	self.zoomSpeed = math.sqrt(2)
	--state stuff
	self.selecting = false
	self.resizing = false
	self.resizeCornerX = 0
	self.resizeCornerY = 0
	--misc
	self.resizeCircleRadius = TILE_SIZE/2
	
	
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

function UI:posNearCorner(worldX,worldY)
	local endX,endY = self.level.width*TILE_SIZE, self.level.height*TILE_SIZE
	for cornerX=0, endX, endX do
		for cornerY=0, endY, endY do
			local dx = worldX - cornerX
			local dy = worldY - cornerY
			if dx*dx + dy*dy <= self.resizeCircleRadius * self.resizeCircleRadius then
				return cornerX==0 and -1 or 1, cornerY==0 and -1 or 1
			end
		end
	end
	return false
end

function UI:toWorldX(x)
	x = x - self.width/2
	x = x / self.zoomFactor
	x = x - self.cameraX
	return x
end
function UI:toWorldY(y)
	y = y - self.height/2
	y = y / self.zoomFactor
	y = y - self.cameraY
	return y
end


function UI:draw()
	love.graphics.push()
	--camera
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.cameraX, self.cameraY)
		
		--bg
		
		love.graphics.setColor(0,0.5,1,1)
		local startX,startY = 0, 0
		local endX,endY = self.level.width*TILE_SIZE, self.level.height*TILE_SIZE
		if self.resizing then
			if self.resizeCornerX==1 then
				endX = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5) * TILE_SIZE
			else
				startX = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5) * TILE_SIZE
			end
			if self.resizeCornerY==1 then
				endY = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5) * TILE_SIZE
			else
				startY = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5) * TILE_SIZE
			end
		end
		love.graphics.rectangle(
			"fill",
			startX, startY,
			endX-startX, endY-startY
		)
		--resize circles
		love.graphics.setColor(settings.col.editor.resizeCircles)
		for cornerX=startX, endX, endX-startX do
			for cornerY=startY, endY, endY-startY do
				love.graphics.circle("fill",cornerX,cornerY,self.resizeCircleRadius)
			end
		end
		
		--objects
		
		--get psoition of objects at the screen edges
		startX, startY = self:toWorldX(0), self:toWorldY(0)
		endX, endY = self:toWorldX(self.width), self:toWorldY(self.height)
		startX, startY = math.ceil(startX/TILE_SIZE), math.ceil(startY/TILE_SIZE)
		endX, endY = math.ceil(endX/TILE_SIZE), math.ceil(endY/TILE_SIZE)
		--and draw all objects between
		for x = startX, endX, 1 do
			for y = startY, endY, 1 do
				local bobj = self.level.background:get(x,y)
				if bobj then bobj:drawAsBackground() end
				
				local pn = self.level.pathNodes:get(x,y)
				if pn then
					pn:draw()
					if pn.next then
						pn:drawConnection()
					end
					if
						pn.prev and
						(pn.prev.x < startX or pn.prev.x > endX or
						pn.prev.y < startY or pn.prev.y > endY)
					then
						pn.prev:drawConnection()
					end
				end
				
				local obj = self.level.foreground:get(x,y)
				if obj then obj:drawAsForeground() end
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

function UI:mouseMoved(x,y,dx,dy)
	if self.resizing then
		-- move camera when at border
	else
		if input.isActive("drag","camera") then
			self.selecting = false
			self.cameraX = self.cameraX + dx/self.zoomFactor
			self.cameraY = self.cameraY + dy/self.zoomFactor
		else
			local cx,cy = self:posNearCorner(self:toWorldX(x),self:toWorldY(y))
			if cx then
				if cx*cy==1 then
					love.mouse.setCursor(love.mouse.getSystemCursor("sizenwse"))
				else
					love.mouse.setCursor(love.mouse.getSystemCursor("sizenesw"))
				end
			else
				love.mouse.setCursor()
			end
		end
	end
end

function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="select" then
			self.selecting = true
		elseif name=="resize" then
			local cx,cy = self:posNearCorner(self:toWorldX(self:getMouseX()),self:toWorldY(self:getMouseY()))
			if cx then
				self.resizing = true
				self.resizeCornerX = cx
				self.resizeCornerY = cy
			end
		end
	end
end

function UI:inputDeactivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="select" then
			if self.selecting then
				self.selecting = false
				self.editor:selectObject(self:getMouseTile())
			end
		elseif name=="resize" then
			if self.resizing then
				self.resizing = false
				--actually resize
				local startX,startY = 0, 0
				local endX,endY = self.level.width, self.level.height
				if self.resizeCornerX==1 then
					endX = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5)
					
					if self.resizeCornerY==1 then
						endY = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
						--top-right: no movement required
					else
						startY = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
						--bottom-right: only Y should be compensated
						UTILS.offsetEverything(self.level,0,-startY)
						self.cameraY = self.cameraY + startY*TILE_SIZE
					end
				else
					startX = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5)
					self.level.width = endX - startX
					if self.resizeCornerY==1 then
						endY = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
						--top-left: only X should be compensated
						UTILS.offsetEverything(self.level,-startX,0)
						self.cameraX = self.cameraX + startX*TILE_SIZE
					else
						startY = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
						--bottom-left: both X and Y should be compensated
						UTILS.offsetEverything(self.level,-startX,-startY)
						self.cameraX = self.cameraX + startX*TILE_SIZE
						self.cameraY = self.cameraY + startY*TILE_SIZE
					end
				end
				self.level.width = endX - startX
				self.level.height = endY - startY
				--get the level details UI reloaded so it displays the right size
				self.editor:reload(self.level)
			end
		end
	end
end

function UI:wheelMoved(x,y)
	if y>0 then
		self.zoomFactor = self.zoomFactor * self.zoomSpeed
	elseif y<0 then
		self.zoomFactor = self.zoomFactor / self.zoomSpeed
	end
	self.cameraX = math.roundPrecision(self.cameraX,self.zoomFactor)
	self.cameraY = math.roundPrecision(self.cameraY,self.zoomFactor)
end

return UI
