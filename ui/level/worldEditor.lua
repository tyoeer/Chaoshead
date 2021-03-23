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
	self.selectionStartX = nil
	self.selectionStartY = nil
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
	return math.floor(x/TILE_SIZE), math.floor(y/TILE_SIZE)
end

function UI:posNearCorner(worldX,worldY)
	--ipairs used because for-looping with the difference as step size gets stuck when the difference is 0
	for _,cornerX in ipairs({ self.level.left, self.level.right+1}) do
		for _,cornerY in ipairs({self.level.top, self.level.bottom+1}) do
			local dx = worldX - cornerX*TILE_SIZE
			local dy = worldY - cornerY*TILE_SIZE
			if dx*dx + dy*dy <= self.resizeCircleRadius * self.resizeCircleRadius then
				return cornerX==self.level.left and -1 or 1, cornerY==self.level.top and -1 or 1
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
	--not exactly one to compensate for float weirdness
	if self.zoomFactor < 0.999 then
		love.graphics.setLineStyle("smooth")
	else
		love.graphics.setLineStyle("rough")
	end
	--camera
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.cameraX, self.cameraY)
		
		--bg
		love.graphics.setColor(settings.col.editor.bg)
		love.graphics.rectangle(
			"fill",
			self.level.left *TILE_SIZE, self.level.top *TILE_SIZE,
			self.level:getWidth() *TILE_SIZE, self.level:getHeight() *TILE_SIZE
		)
		
		--resize circles
		love.graphics.setColor(settings.col.editor.resizeCircles)
		--ipairs used because for-looping with the difference as step size gets stuck when the difference is 0
		for _,cornerX in ipairs({ self.level.left, self.level.right+1}) do
			for _,cornerY in ipairs({self.level.top, self.level.bottom+1}) do
				love.graphics.circle("fill",cornerX*TILE_SIZE,cornerY*TILE_SIZE,self.resizeCircleRadius)
			end
		end
		
		--get position of objects at the screen edges
		startX, startY = self:toWorldX(0), self:toWorldY(0)
		endX, endY = self:toWorldX(self.width), self:toWorldY(self.height)
		startX, startY = math.floor(startX/TILE_SIZE), math.floor(startY/TILE_SIZE)
		endX, endY = math.floor(endX/TILE_SIZE), math.floor(endY/TILE_SIZE)
		
		--objects
		do
			
			--get all objects between
			--storing them in a list should optimize whne there's lots of empty space on teh screen a.k.a. when zoomed out
			--adds extra overheads that doesn't cause improvements when the whole screen is covered (every grid space and layer)
			--but that scenario should be pretty rare (and then this is hopefully still performant enough
			local fg = {} --foreground
			local bg = {} --background
			local pn = {} --path nodes
			for x = startX, endX, 1 do
				for y = startY, endY, 1 do
					local bobj = self.level.background:get(x,y)
					if bobj then table.insert(bg,bobj) end
					
					local node = self.level.pathNodes:get(x,y)
					if node then table.insert(pn,node) end
					
					local obj = self.level.foreground:get(x,y)
					if obj then table.insert(fg,obj) end
				end
			end
			
			--draw shapes
			for _,v in ipairs(bg) do
				v:drawShape()
			end
			for _,v in ipairs(pn) do
				v:drawShape()
			end
			for _,v in ipairs(fg) do
				v:drawShape()
			end
			
			--draw path connections
			for _,node in ipairs(pn) do
				if node.next then
					node:drawConnection()
				end
				--only draw connection with previous if it's offscreen and won't get drawn otherwise
				if
					node.prev and
					(node.prev.x < startX or node.prev.x > endX or
					node.prev.y < startY or node.prev.y > endY)
				then
					node.prev:drawConnection()
				end
			end
			
			--draw text
			for _,v in ipairs(bg) do
				v:drawText()
			end
			for _,v in ipairs(fg) do
				v:drawText()
			end
			
			--draw outlines
			for _,v in ipairs(bg) do
				v:drawOutline()
			end
			for _,v in ipairs(pn) do
				v:drawOutline()
			end
			for _,v in ipairs(fg) do
				v:drawOutline()
			end
		end
		
		--selection
		if self.editor.selection then
			self.editor.selection:draw(startX,startY, endX,endY)
		end
		--area being selected
		if self.selectStartX then
			love.graphics.setLineWidth(2)
			love.graphics.setColor(settings.col.editor.selectionAreaOutline)
			love.graphics.rectangle("line",
				self.selectStartX +0.5, self.selectStartY+0.5,
				self:toWorldX(self:getMouseX()) - self.selectStartX-1,
				self:toWorldY(self:getMouseY()) - self.selectStartY-1
			)
		end
		
		--hover
		local x,y = self:getMouseTile()
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.rectangle(
			"fill",
			x*TILE_SIZE, y*TILE_SIZE,
			TILE_SIZE, TILE_SIZE
		)
	love.graphics.pop()
end

function UI:mouseMoved(x,y,dx,dy)
	if self.resizing then
		--resize level
		if self.resizeCornerX==1 then
			self.level.right = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5) - 1
			if self.resizeCornerY==1 then
				self.level.bottom = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5) - 1
			else
				self.level.top = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
			end
		else
			self.level.left = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5)
			if self.resizeCornerY==1 then
				self.level.bottom = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5) - 1
			else
				self.level.top = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
			end
		end
		
		--make sure left stays left of right and top stays above bottom
		if self.level.left > self.level.right then
			-- +1 and -1 are to make it mirror in the edge and not in the tile
			self.level.left, self.level.right = self.level.right+1, self.level.left-1
			self.resizeCornerX = -self.resizeCornerX
		end
		if self.level.top > self.level.bottom then
			-- +1 and -1 are to make it mirror in the edge and not in the tile
			self.level.top, self.level.bottom = self.level.bottom+1, self.level.top-1
			self.resizeCornerY = -self.resizeCornerY
		end
		
		--get the level details UI reloaded so it displays the right size
		self.editor:reload(self.level)
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
		if name=="selectOnly" or name=="selectAdd" or name=="deselectSub" then
			self.selecting = true
		elseif name=="selectAddArea" or name=="deselectSubArea" then
			self.selectStartX = self:toWorldX(self:getMouseX())
			self.selectStartY = self:toWorldY(self:getMouseY())
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
		if name=="selectOnly" then
			if self.selecting then
				self.selecting = false
				self.editor:selectOnly(self:getMouseTile())
			end
		elseif name=="selectAdd" then
			if self.selecting then
				self.selecting = false
				self.editor:selectAdd(self:getMouseTile())
			end
		elseif name=="deselectSub" then
			if self.selecting then
				self.selecting = false
				self.editor:deselectSub(self:getMouseTile())
			end
		elseif name=="selectAddArea" then
			local fromX, fromY = math.floor(self.selectStartX/TILE_SIZE), math.floor(self.selectStartY/TILE_SIZE)
			local endX, endY = self:getMouseTile()
			self.editor:selectAddArea(
				math.min(fromX,endX), math.min(fromY,endY),
				math.max(fromX,endX), math.max(fromY,endY)
			)
			self.selectStartX = nil
			self.selectStartY = nil
		elseif name=="deselectSubArea" then
			local fromX, fromY = math.floor(self.selectStartX/TILE_SIZE), math.floor(self.selectStartY/TILE_SIZE)
			local endX, endY = self:getMouseTile()
			self.editor:deselectSubArea(
				math.min(fromX,endX), math.min(fromY,endY),
				math.max(fromX,endX), math.max(fromY,endY)
			)
			self.selectStartX = nil
			self.selectStartY = nil
		elseif name=="resize" then
			if self.resizing then
				self.resizing = false
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
