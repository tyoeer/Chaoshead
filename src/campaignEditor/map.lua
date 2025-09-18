-- local Clipboard = require("tools.clipboard")

local UI = Class("CampaignMapEditor",require("ui.base.node"))

local theme = Settings.theme.editor.campaign

function UI:initialize(editor)
	self.editor = editor
	self.campaign = editor.campaign
	
	--camera stuff
	self.cameraX = 0
	self.cameraY = 0
	self.zoomFactor = 1
	self.zoomSpeed = Settings.misc.editor.zoomSpeed
	self.moveSpeed = Settings.misc.editor.cameraMoveSpeed
	
	-- --state stuff
	-- self.holding = nil
	-- self.handX = nil
	-- self.handY = nil
	
	-- self.selecting = false
	-- self.selectionStartX = nil
	-- self.selectionStartY = nil
	
	-- self.resizing = false
	-- self.resizeCornerX = 0
	-- self.resizeCornerY = 0
	
	-- --misc
	-- self.resizeCircleRadius = TILE_SIZE/2
	
	
	--UI stuff
	UI.super.initialize(self)
end

function UI:reload(campaign)
	self.campaign = campaign
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

function UI:selectArea()
	local fromX, fromY = self.selectStartX, self.selectStartY
	local endX, endY = self:getMouseWorldPos()
	self.editor:selectAddArea(
		math.min(fromX,endX), math.min(fromY,endY),
		math.max(fromX,endX), math.max(fromY,endY)
	)
	self.selectStartX = nil
	self.selectStartY = nil
end

function UI:deselectArea()
	local fromX, fromY = self.selectStartX, self.selectStartY
	local endX, endY = self:getMouseWorldPos()
	self.editor:deselectSubArea(
		math.min(fromX,endX), math.min(fromY,endY),
		math.max(fromX,endX), math.max(fromY,endY)
	)
	self.selectStartX = nil
	self.selectStartY = nil
end

-- function UI:initHand()
-- 	self.holding = true
-- 	self:updateHandPosition(self:getMousePos())
-- 	self.selecting = false
-- 	self.resizing = false
-- end

-- function UI:updateHandPosition(x,y)
-- 	local w = self.editor.hand.world:getWidth()
-- 	local h = self.editor.hand.world:getHeight()
-- 	local wx = self:toWorldX(x)
-- 	local wy = self:toWorldY(y)
-- 	-- -0.5 because the clipboard world starts at (1,1)
-- 	-- only .5 because we want to move around the center, not the corner
-- 	-- (I think not sure if that part of explanation is completely, but testing shows that this works)
-- 	self.handX = math.floor(wx/TILE_SIZE - w/2 - 0.5)
-- 	self.handY = math.floor(wy/TILE_SIZE - h/2 - 0.5)
-- end

-- function UI:clearHand()
-- 	self.holding = false
-- 	self.handX, self.handY = nil, nil
-- end

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


function UI:drawNodes()
	
	for node in self.campaign.nodes:iterate() do
		--the node itself
		love.graphics.setColor(theme.nodes.colors[node.type] or theme.nodes.colors["$UnknownNodeType"])
		love.graphics.circle("fill", node.x, node.y, node:getRadius())
		
		-- direct connections
		love.graphics.setColor(theme.directConnections)
		for _,pNode in ipairs(node.prev) do
			love.graphics.line(node.x,node.y, pNode.x,pNode.y)
		end
		
		-- smooth connections
		local stack = {}
		local function process(node)
			table.insert(stack, node.x)
			table.insert(stack, node.y)
			if node.type=="path" or #stack<=2 then
				for _,node in ipairs(node.prev) do
					process(node)
				end
			else
				local bez = love.math.newBezierCurve(stack)
				love.graphics.line(bez:render())
			end
			table.remove(stack)
			table.remove(stack)
		end
		
		if node.type~="path" then
			love.graphics.setColor(theme.smoothConnections)
			process(node)
		end
	end
end

function UI:drawSelection()
	love.graphics.setColor(theme.selection)
	love.graphics.setLineWidth(1)
	for node in self.editor.selection:iterate() do
		love.graphics.circle("line", node.x, node.y, node:getRadius()+10)
	end
end

function UI:draw()
	love.graphics.clear(theme.background)
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
		
		--screen edge
		local startX, startY = self:toWorldX(0), self:toWorldY(0)
		local endX, endY = self:toWorldX(self.width), self:toWorldY(self.height)
		
		self:drawNodes()
		
		-- origin axis
		love.graphics.setColor(theme.origin)
		love.graphics.line(0,startY, 0,endY)
		love.graphics.line(startX,0, endX,0)
		
		-- if self.holding then
		-- 	--highlight where the stuff to place is
		-- 	local drawArea = math.abs( (startX-endX+1) * (startY-endY+1) )
		-- 	local levelArea = self.editor.hand:getWidth() * self.editor.hand:getHeight()
			
		-- 	love.graphics.setColor(theme.level.handHighlight)
		-- 	if drawArea >= levelArea then
		-- 		for x = 1, self.editor.hand:getWidth(), 1 do
		-- 			for y = 1, self.editor.hand:getHeight(), 1 do
		-- 				if self.editor.hand.mask:get(x,y) then
		-- 					love.graphics.rectangle("fill", (x+self.handX)*TILE_SIZE, (y+self.handY)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
		-- 				end
		-- 			end
		-- 		end
		-- 	else
		-- 		for x = startX-self.handX, endX-self.handX, 1 do
		-- 			for y = startY-self.handY, endY-self.handY, 1 do
		-- 				if self.editor.hand.mask:get(x,y) then
		-- 					love.graphics.rectangle("fill", (x+self.handX)*TILE_SIZE, (y+self.handY)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
		-- 				end
		-- 			end
		-- 		end
		-- 	end
			
		-- 	--object/clipboard to place
		-- 	if self.editor.hand:isInstanceOf(Clipboard) then
		-- 		love.graphics.push()
		-- 			love.graphics.translate(self.handX*TILE_SIZE, self.handY*TILE_SIZE)
		-- 			self:drawObjects(
		-- 				self.editor.hand.world,
		-- 				startX-self.handX, startY-self.handY,
		-- 				endX-self.handX, endY-self.handY
		-- 			)
		-- 		love.graphics.pop()
		-- 	end
		-- else
		-- 	--area being selected
			if self.selecting == "area" then
				love.graphics.setLineWidth(2)
				love.graphics.setColor(theme.selectingArea)
				love.graphics.rectangle("line",
					self.selectStartX +0.5, self.selectStartY+0.5,
					self:toWorldX(self:getMouseX()) - self.selectStartX-1,
					self:toWorldY(self:getMouseY()) - self.selectStartY-1
				)
			end
			
		-- 	--highlight
		-- 	local x,y = self:getMouseTile()
		-- 	love.graphics.setColor(theme.level.hoverHighlight)
		-- 	love.graphics.rectangle(
		-- 		"fill",
		-- 		x*TILE_SIZE, y*TILE_SIZE,
		-- 		TILE_SIZE, TILE_SIZE
		-- 	)
		-- end
		
		--selection
		if self.editor.selection then
			self:drawSelection()
		end
	love.graphics.pop()
end


function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" then
		if false and self.holding then -- TODO
			-- if name=="placeHand" or name=="releaseHand" or name=="placeAndReleaseHand" then
			-- 	self.placing = true
			-- end
		else
			if name=="selectOnly" or name=="selectAdd" or name=="deselectSub" or name=="deselectArea" then
				if Input.isActive("selectAreaModifier","editor") then
					self.selectStartX, self.selectStartY = self:getMouseWorldPos()
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
					self.selectStartX, self.selectStartY = self:getMouseWorldPos()
					self.selecting = "area"
				end
			end
		end
	end
end

function UI:inputDeactivated(name,group, isCursorBound)
	if group=="editor" then
		if false and self.holding then -- TODO
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
						self.editor:selectOnly(self:getMouseWorldPos())
					end
					self.selecting = false
				end
			elseif name=="selectAdd" then
				if self.selecting then
					if self.selecting=="area" then
						self:selectArea()
					else
						self.editor:selectAdd(self:getMouseWorldPos())
					end
					self.selecting = false
				end
			elseif name=="deselectSub" then
				if self.selecting then
					if self.selecting=="area" then
						self:deselectArea()
					else
						self.editor:deselectSub(self:getMouseWorldPos())
					end
					self.selecting = false
				end
			elseif name=="deselectArea" then
				if self.selecting=="area" then
					self:deselectArea()
					self.selecting = false
				end
				--do nothing otherwise because this input is doubly mapped to camera.drag
			end
		end
	end
end


function UI:mouseMoved(x,y,dx,dy)
	-- if self.holding then
	-- 	self:updateHandPosition(x,y)
	-- end
	
	if Input.isActive("drag","camera") then
		self.cameraX = self.cameraX + dx/self.zoomFactor
		self.cameraY = self.cameraY + dy/self.zoomFactor
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
	
	-- --stop placing something
	-- self.placing = false
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
	--Snap to pixel to prevent tiny little offsets from messing with lines when zoomed out
	self.cameraX = math.roundPrecision(self.cameraX,1/self.zoomFactor)
	self.cameraY = math.roundPrecision(self.cameraY,1/self.zoomFactor)
end

return UI
