local Clipboard = require("tools.clipboard")

local UI = Class(require("ui.base.node"))

local theme = Settings.theme.editor

function UI:initialize(editor)
	self.editor = editor
	self.level = editor.level
	
	--camera stuff
	self.cameraX = 0
	self.cameraY = 0
	self.zoomFactor = 1
	self.zoomSpeed = Settings.misc.editor.zoomSpeed
	self.moveSpeed = Settings.misc.editor.cameraMoveSpeed
	
	--state stuff
	self.holding = nil
	self.handX = nil
	self.handY = nil
	
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
end

function UI:reload(level)
	self.level = level
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


function UI:getWorldPos(x,y)
	return self:toWorldX(x), self:toWorldY(y)
end

function UI:getMouseWorldPos()
	return self:getWorldPos(self:getMousePos())
end

function UI:getTileAt(x,y)
	return math.floor(x/TILE_SIZE), math.floor(y/TILE_SIZE)
end

function UI:getMouseTile()
	return self:getTileAt(self:getMouseWorldPos())
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


function UI:selectArea()
	local fromX, fromY = math.floor(self.selectStartX/TILE_SIZE), math.floor(self.selectStartY/TILE_SIZE)
	local endX, endY = self:getMouseTile()
	self.editor:selectAddArea(
		math.min(fromX,endX), math.min(fromY,endY),
		math.max(fromX,endX), math.max(fromY,endY)
	)
	self.selectStartX = nil
	self.selectStartY = nil
end

function UI:deselectArea()
	local fromX, fromY = math.floor(self.selectStartX/TILE_SIZE), math.floor(self.selectStartY/TILE_SIZE)
	local endX, endY = self:getMouseTile()
	self.editor:deselectSubArea(
		math.min(fromX,endX), math.min(fromY,endY),
		math.max(fromX,endX), math.max(fromY,endY)
	)
	self.selectStartX = nil
	self.selectStartY = nil
end

function UI:initHand()
	self.holding = true
	self:updateHandPosition(self:getMousePos())
	self.selecting = false
	self.resizing = false
end

function UI:updateHandPosition(x,y)
	local w = self.editor.hand.world:getWidth()
	local h = self.editor.hand.world:getHeight()
	local wx = self:toWorldX(x)
	local wy = self:toWorldY(y)
	-- -0.5 because the clipboard world starts at (1,1)
	-- only .5 because we want to move around the center, not the corner
	-- (I think not sure if that part of explanation is completely, but testing shows that this works)
	self.handX = math.floor(wx/TILE_SIZE - w/2 - 0.5)
	self.handY = math.floor(wy/TILE_SIZE - h/2 - 0.5)
end

function UI:clearHand()
	self.holding = false
	self.handX, self.handY = nil, nil
end

-- EVENTS

function UI:update(dt)
	local moved = false
	if Input.isActive("up","camera") then
		self.cameraY = self.cameraY + self.moveSpeed/self.zoomFactor*dt
		moved = true
	end
	if Input.isActive("down","camera") then
		self.cameraY = self.cameraY - self.moveSpeed/self.zoomFactor*dt
		moved = true
	end
	if Input.isActive("left","camera") then
		self.cameraX = self.cameraX + self.moveSpeed/self.zoomFactor*dt
		moved = true
	end
	if Input.isActive("right","camera") then
		self.cameraX = self.cameraX - self.moveSpeed/self.zoomFactor*dt
		moved = true
	end
	if moved then
		--relative to the world, the mouse DID move
		local mx, my = self:getMousePos()
		self:mouseMoved(mx, my, 0, 0)
	end
end


function UI:drawObjects(level, startX, startY, endX, endY)
	local drawArea = math.abs( (startX-endX+1) * (startY-endY+1) )
	local levelArea = level:getWidth() * level:getHeight()
	--optimisation to just draw all the objects in the level instead of the viewport
	--in case the viewport is bigger than the level and finding all the objects in the vieport would be more work
	local drawGlobal = drawArea >= levelArea
	
	--get all objects that should be drawn
	--storing them in a list should optimize when there's lots of empty space on the screen a.k.a. when zoomed out
	--adds extra overheads that doesn't cause improvements when the whole screen is covered (every grid space and layer)
	--but that scenario should be pretty rare (and then this is hopefully still performant enough
	local fg = {} --foreground
	local bg = {} --background
	local pn = {} --path nodes
	if drawGlobal then
		for obj in level.objects:iterate() do
			if obj.layer=="foreground" then
				table.insert(fg,obj)
			else
				table.insert(bg,obj)
			end
		end
		
		for path in level.paths:iterate() do
			for node in path:iterateNodes() do
				table.insert(pn,node)
			end
		end
	else
		for x = startX, endX, 1 do
			for y = startY, endY, 1 do
				local bobj = level.background:get(x,y)
				if bobj then table.insert(bg,bobj) end
				
				local node = level.pathNodes:get(x,y)
				if node then table.insert(pn,node) end
				
				local obj = level.foreground:get(x,y)
				if obj then table.insert(fg,obj) end
			end
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
	if self.zoomFactor >= 1/Settings.misc.editor.textLod then
		for _,v in ipairs(bg) do
			v:drawText()
		end
		for _,v in ipairs(fg) do
			v:drawText()
		end
	end
	
	--draw outlines
	if self.zoomFactor >= 1/Settings.misc.editor.outlineLod then
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
end

function UI:draw()
	love.graphics.clear(theme.level.outsideWorld)
	--not exactly one to compensate for float weirdness
	if self.zoomFactor < 0.999 then
		love.graphics.setLineStyle("smooth")
	else
		love.graphics.setLineStyle("rough")
	end
	--camera
	love.graphics.push()
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.cameraX, self.cameraY)
		
		--bg
		love.graphics.setColor(theme.level.worldBackground)
		love.graphics.rectangle(
			"fill",
			self.level.left *TILE_SIZE, self.level.top *TILE_SIZE,
			self.level:getWidth() *TILE_SIZE, self.level:getHeight() *TILE_SIZE
		)
		
		--resize circles
		if not self.holding then
			love.graphics.setColor(theme.level.resizeCircles)
			--ipairs used because for-looping with the difference as step size gets stuck when the difference is 0
			for _,cornerX in ipairs({ self.level.left, self.level.right+1}) do
				for _,cornerY in ipairs({self.level.top, self.level.bottom+1}) do
					love.graphics.circle("fill",cornerX*TILE_SIZE,cornerY*TILE_SIZE,self.resizeCircleRadius)
				end
			end
		end
		
		--get position of objects at the screen edges
		local startX, startY = self:toWorldX(0), self:toWorldY(0)
		local endX, endY = self:toWorldX(self.width), self:toWorldY(self.height)
		local startX, startY = math.floor(startX/TILE_SIZE), math.floor(startY/TILE_SIZE)
		local endX, endY = math.floor(endX/TILE_SIZE), math.floor(endY/TILE_SIZE)
		
		--objects
		self:drawObjects(self.level, startX,startY, endX,endY)
		
		if self.holding then
			--highlight where the stuff to place is
			local drawArea = math.abs( (startX-endX+1) * (startY-endY+1) )
			local levelArea = self.editor.hand:getWidth() * self.editor.hand:getHeight()
			
			love.graphics.setColor(theme.level.handHighlight)
			if drawArea >= levelArea then
				for x = 1, self.editor.hand:getWidth(), 1 do
					for y = 1, self.editor.hand:getHeight(), 1 do
						if self.editor.hand.mask:get(x,y) then
							love.graphics.rectangle("fill", (x+self.handX)*TILE_SIZE, (y+self.handY)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
						end
					end
				end
			else
				for x = startX-self.handX, endX-self.handX, 1 do
					for y = startY-self.handY, endY-self.handY, 1 do
						if self.editor.hand.mask:get(x,y) then
							love.graphics.rectangle("fill", (x+self.handX)*TILE_SIZE, (y+self.handY)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
						end
					end
				end
			end
			
			--object/clipboard to place
			if self.editor.hand:isInstanceOf(Clipboard) then
				love.graphics.push()
					love.graphics.translate(self.handX*TILE_SIZE, self.handY*TILE_SIZE)
					self:drawObjects(
						self.editor.hand.world,
						startX-self.handX, startY-self.handY,
						endX-self.handX, endY-self.handY
					)
				love.graphics.pop()
			end
		else
			--area being selected
			if self.selecting == "area" then
				love.graphics.setLineWidth(2)
				love.graphics.setColor(theme.level.selectingArea)
				love.graphics.rectangle("line",
					self.selectStartX +0.5, self.selectStartY+0.5,
					self:toWorldX(self:getMouseX()) - self.selectStartX-1,
					self:toWorldY(self:getMouseY()) - self.selectStartY-1
				)
			end
			
			--highlight
			local x,y = self:getMouseTile()
			love.graphics.setColor(theme.level.hoverHighlight)
			love.graphics.rectangle(
				"fill",
				x*TILE_SIZE, y*TILE_SIZE,
				TILE_SIZE, TILE_SIZE
			)
		end
		--selection
		if self.editor.selection then
			self.editor.selection:draw(startX,startY, endX,endY, self.zoomFactor)
		end
	love.graphics.pop()
end


function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" then
		if self.holding then
			if name=="placeHand" or name=="releaseHand" or name=="placeAndReleaseHand" then
				self.placing = true
			end
		else
			if name=="selectOnly" or name=="selectAdd" or name=="deselectSub" or name=="deselectArea" then
				if Input.isActive("selectAreaModifier","editor") then
					self.selectStartX = self:toWorldX(self:getMouseX())
					self.selectStartY = self:toWorldY(self:getMouseY())
					self.selecting = "area"
				else
					self.selecting = true
				end
			elseif name=="selectAreaModifier"  then
				if Input.isActive("selectOnly","editor")
					or Input.isActive("selectAdd","editor")
					or Input.isActive("deselectSub","editor")
					or Input.isActive("deselectArea","editor")
				then
					self.selectStartX = self:toWorldX(self:getMouseX())
					self.selectStartY = self:toWorldY(self:getMouseY())
					self.selecting = "area"
				end
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
end

function UI:inputDeactivated(name,group, isCursorBound)
	if group=="editor" then
		if self.holding then
			if self.placing then
				--only stop placing it's a related input
				--otherwise unrelated inputs (on duplicate binds) prevent us from placing stuff
				if name=="placeHand" then
					self.editor:place(self.handX, self.handY, false)
					self.placing = false
				elseif name=="placeAndReleaseHand" then
					self.editor:place(self.handX, self.handY, true)
					self.placing = false
				elseif name=="releaseHand" then
					self.editor:releaseHold()
					self.placing = false
				end
			end
		else
			if name=="selectOnly" then
				if self.selecting then
					if self.selecting=="area" then
						self:selectArea()
					else
						self.editor:selectOnly(self:getMouseTile())
					end
					self.selecting = false
				end
			elseif name=="selectAdd" then
				if self.selecting then
					if self.selecting=="area" then
						self:selectArea()
					else
						self.editor:selectAdd(self:getMouseTile())
					end
					self.selecting = false
				end
			elseif name=="deselectSub" then
				if self.selecting then
					if self.selecting=="area" then
						self:deselectArea()
					else
						self.editor:deselectSub(self:getMouseTile())
					end
					self.selecting = false
				end
			elseif name=="deselectArea" then
				if self.selecting=="area" then
					self:deselectArea()
					self.selecting = false
				end
				--do nothing otherwise because this input is doubly mapped to camera.drag
			elseif name=="resize" then
				if self.resizing then
					self.resizing = false
				end
			end
		end
	end
end


function UI:mouseMoved(x,y,dx,dy)
	if self.holding then
		self:updateHandPosition(x,y)
	end
	if self.resizing then
		--calculate new size
		local top, bottom = self.level.top, self.level.bottom
		local right, left = self.level.right, self.level.left
		if self.resizeCornerX==1 then
			right = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5) - 1
			if self.resizeCornerY==1 then
				bottom = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5) - 1
			else
				top = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
			end
		else
			left = math.floor((self:toWorldX(self:getMouseX()) / TILE_SIZE)+0.5)
			if self.resizeCornerY==1 then
				bottom = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5) - 1
			else
				top = math.floor((self:toWorldY(self:getMouseY()) / TILE_SIZE)+0.5)
			end
		end
		
		--make sure left stays left of right and top stays above bottom
		if left > right then
			-- +1 and -1 are to make it mirror in the edge and not in the tile
			left, right = right+1, left-1
			self.resizeCornerX = -self.resizeCornerX
		end
		if top > bottom then
			-- +1 and -1 are to make it mirror in the edge and not in the tile
			top, bottom = bottom+1, top-1
			self.resizeCornerY = -self.resizeCornerY
		end
		
		--resize
		self.editor:resizeLevel(top, right, bottom, left)
	else
		if Input.isActive("drag","camera") then
			self.cameraX = self.cameraX + dx/self.zoomFactor
			self.cameraY = self.cameraY + dy/self.zoomFactor
		end
		--update cursor symbol
		local cx,cy = self:posNearCorner(self:toWorldX(x),self:toWorldY(y))
		if cx and not self.holding then
			if cx*cy==1 then
				love.mouse.setCursor(love.mouse.getSystemCursor("sizenwse"))
			else
				love.mouse.setCursor(love.mouse.getSystemCursor("sizenesw"))
			end
		else
			love.mouse.setCursor()
		end
	end
	--stop selecting a single tile when you have moved the cursor
	if (Input.isActive("selectOnly","editor")
		or Input.isActive("selectAdd","editor")
		or Input.isActive("deselectSub","editor")
		or Input.isActive("deselectArea","editor"))
		and self.selecting~="area"
	then
		self.selecting = false
	end
	
	--stop placing something
	self.placing = false
end

function UI:wheelMoved(sx,sy)
	local ax,ay = self:getMouseWorldPos()
	if sy>0 then
		self.zoomFactor = self.zoomFactor * self.zoomSpeed
	elseif sy<0 then
		self.zoomFactor = self.zoomFactor / self.zoomSpeed
	end
	local bx,by = self:getMouseWorldPos()
	-- make sure the point under the cursor stays under the cursor
	self.cameraX = self.cameraX + bx - ax
	self.cameraY = self.cameraY + by - ay
	--Prevent tiny little offsets from messing with lines when zoomed out
	self.cameraX = math.roundPrecision(self.cameraX,self.zoomFactor)
	self.cameraY = math.roundPrecision(self.cameraY,self.zoomFactor)
end

return UI
