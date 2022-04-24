--[[

Auto fills the selection by continueing lines of foreground objects, with the numerical properties following a lineair series.
A line of objects starts with exactly 2 objects, no more, no less.
Tries to handle weird/non-rectangular selections gracefully, but gives no guarantees. 

]]--

-- Utilities

local P = require("levelhead.data.properties")

local dirs = {
	up    = {x= 0,y=-1},
	left  = {x=-1,y= 0},
	down  = {x= 0,y= 1},
	right = {x= 1,y= 0}
}

local function err(mes)
	error(mes,2)
end
local function errF(mes, ...)
	err(string.format(mes,...))
end

-- Begin

if not selection then
	err("No selection!")
end

-- Find which way to expand

local minX, minY = math.huge, math.huge
local maxX, maxY = -math.huge, -math.huge

local borders = {}
for dir,_ in pairs(dirs) do
	borders[dir] = false
end

for obj in selection.contents.foreground:iterate() do
	for dir, d in pairs(dirs) do
		minX = math.min(minX, obj.x)
		maxX = math.max(maxX, obj.x)
		minY = math.min(minY, obj.y)
		maxY = math.max(maxY, obj.y)
		if not selection.mask:has(obj.x+d.x, obj.y+d.y) then
			borders[dir] = true
		end
	end
end

if minX == math.huge then
	err("No objects in the selection!")
end

local n = 0
local expandDir
for dir,_ in pairs(dirs) do
	if borders[dir] then
		n = n + 1
	else
		expandDir = dir
	end
end
if n < 3 then -- there's  more than one direction to expand in
	errF("Can't expand into %d directions!",4-n)
elseif n==4 then
	err("Can't figure out in which direction to expand!")
end

local dx = dirs[expandDir].x
local dy = dirs[expandDir].y
local isHor = dy==0
local from, to
if isHor then
	from = minY
	to = maxY
else
	from = minX
	to = maxX
end

-- Start filling

for i=from,to,1 do
	local x,y
	if isHor then
		y = i
		x = dx==1 and minX or maxX
	else
		x = i
		y = dy==1 and minY or maxY
	end
	if selection.mask:has(x,y) then -- allow gaps in the selection
		if not selection.mask:has(x+dx,y+dy) then
			errF("Expected (%d,%d) to be selected!", x+dx, y+dy)
		end
		local a = level.foreground[x][y]
		local b = level.foreground[x+dx][y+dy]
		if not a or not b then
			errF("Expected foreground objects at (%d,%d) and (%d,%d)!\nDid you make sure to select 2 source objects?", x,y, x+dx,y+dy)
		end
		if a.id ~= b.id then
			errF("Expected foreground objects at (%d,%d) and (%d,%d) to be the same element!", x,y, x+dx,y+dy)
		end
		
		-- Figure out which properties to increase
		
		local deltas = {}
		for propId in a:iterateProperties() do
			-- use raw for numerical increases from hybrid properties
			local vA = a:getPropertyRaw(propId)
			local vB = b:getPropertyRaw(propId)
			local type = P:getMappingType(propId)
			if type=="Hybrid" or type=="None" then
				--Numerical property, increase
				if vA~=vB then
					deltas[propId] = {
						start = vA,
						step = vB - vA,
					}
				end
			else
				-- No logical series to follow verify they're the same
				if vA~=vB then
					errF("Expected objects at (%d,%d) and (%d,%d) to have non-numerical property %s be the same!", x,y, x+dx,y+dy, P:getName(propId))
				end
			end
		end
		
		-- Actually create and place the new objects
		
		x = x + 2*dx
		y = y + 2*dy
		local i = 2
		while selection.mask:has(x,y) do
			if level.foreground[x][y] then
				errF("Expected air to fill at (%d,%d)!",x,y)
			end
			local new = a:clone()
			
			for propId, delta in pairs(deltas) do
				new:setPropertyRaw(propId, delta.start + i * delta.step)
			end
			
			level:addForegroundObject(new,x,y)
			
			x = x + dx
			y = y + dy
			i = i + 1
		end
	end
end
