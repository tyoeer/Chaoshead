--[[

Select 2 instances of the group of objects you want to expand.
- You can leave empty space between the groups
- The groups can be single tiles
- The groups have to be rectangular, but can be any size you want
- If you are expanding both horizontally and vertically, the bottom-right group in the 2x2 set of object groups you would expect get ignored and is optional
- You can NOT have fully empty rows or columns within a group. As a workaround, use a dummy object you can delete later.

Select the area around the groups of objects you want to expand the groups into.
- You have to select the whole rectangle to prevent issues with a forgotten part of the selection being somewhere else
- The expansion area gets rounded to the size of your object group, and nothing will be placed outside the selection
- You can expand in all 4 direction

Run this script.
- Properties of objects and paths are linearly extrapolated in all directions
- You can expand object groups and extrapolate their properties in multiple directions at once

]]

---@diagnostic disable-next-line: undefined-global
local level = level
---@cast level Level

local Clipboard = require("tools.clipboard")
local SelectionMask = require("tools.selection.mask")
local PropData = require("levelhead.data.properties")

local function printTable(t)
	local keys = {}
	for k,_ in pairs(t) do
		table.insert(keys, k)
	end
	table.sort(keys)
	for _,key in ipairs(keys) do
		print(key, t[key])
	end
end

---@return {minX:number, minY:number, maxX:number, maxY: number}
local function findObjectRegion()
	local region = {
		minX = math.huge,
		minY = math.huge,
		maxX = -math.huge,
		maxY = -math.huge,
	}
	
	for obj in selection.contents.foreground:iterate() do
		region.minX = math.min(region.minX, obj.x)
		region.minY = math.min(region.minY, obj.y)
		region.maxX = math.max(region.maxX, obj.x)
		region.maxY = math.max(region.maxY, obj.y)
	end
	for obj in selection.contents.background:iterate() do
		region.minX = math.min(region.minX, obj.x)
		region.minY = math.min(region.minY, obj.y)
		region.maxX = math.max(region.maxX, obj.x)
		region.maxY = math.max(region.maxY, obj.y)
	end
	for node in selection.contents.pathNodes:iterate() do
		region.minX = math.min(region.minX, node.x)
		region.minY = math.min(region.minY, node.y)
		region.maxX = math.max(region.maxX, node.x)
		region.maxY = math.max(region.maxY, node.y)
	end
	
	return region
end

---@return {rows:number[], columns: number[]}
local function findEmptyLines(region)
	local emptyColumns = {}
	-- we can shrink the search region by from each side because if those columns/rows have objects for sure, otherwise the region wouldn't extend so far
	for x=region.minX+1, region.maxX-1 do
		local empty = true

		for y=region.minY, region.maxY do
			if level.foreground[x][y]
				or level.background[x][y]
				or level.pathNodes[x][y]
			then
				empty = false
				break
			end
		end

		if empty then
			table.insert(emptyColumns,x)
		end
	end
	
	local emptyRows = {}
	-- we can shrink the search region by from each side because if those columns/rows have objects for sure, otherwise the region wouldn't extend so far
	for y=region.minY+1, region.maxY-1 do
		local empty = true
		
		for x=region.minX, region.maxX do
			if level.foreground[x][y]
				or level.background[x][y]
				or level.pathNodes[x][y]
			then
				empty = false
				break
			end
		end

		if empty then
			table.insert(emptyRows, y)
		end
	end
	
	return {
		rows=emptyRows,
		columns=emptyColumns,
	}
end

local function cellSize()
	local region = findObjectRegion()
	assert(region.minX~=math.huge, "No objects/pathNodes in selection, have nothing to expand from")
	print("region")
	printTable(region)
	local emptyLines = findEmptyLines(region)
	
	local sMinX, sMinY, sMaxX, sMaxY = selection.mask:getBounds()
	
	local selWidth = sMaxX-sMinX+1
	local selHeight = sMaxY-sMinY+1
	assert(selWidth*selHeight==selection.mask.nTiles, "Not full rectangle selected")
	
	local extendPosX = sMaxX~=region.maxX
	local extendNegX = sMinX~=region.minX
	local extendPosY = sMaxY~=region.maxY
	local extendNegY = sMinY~=region.minY
	
	
	local cell = {
		minX = region.minX,
		minY = region.minY,
		extendX = extendPosX or extendNegX,
		extendY = extendPosY or extendNegY,
	}
	
	local rWidth = region.maxX - region.minX + 1
	local rHeight = region.maxY - region.minY + 1
	
	if not cell.extendX then
		cell.maxX = region.maxX
	elseif #emptyLines.columns > 0 then
		cell.maxX = emptyLines.columns[1]-1
		for i, x in ipairs(emptyLines.columns) do
			if i~=1 then
				local prevX = emptyLines.columns[i-1]
				if x-1 ~= prevX then
					error(string.format(
						"Failed detecting object groups: multiple disconnected empty columns at x %i and %i",
						prevX, x
					))
				end
			end
		end
	else
		if rWidth % 2 == 1 then
			error("Content width is uneven without air columns, can't neatly divide it in two")
		end
		cell.maxX = cell.minX + rWidth/2 -1
	end
	
	if not cell.extendY then
		cell.maxY = region.maxY
	elseif #emptyLines.rows > 0 then
		cell.maxY = emptyLines.rows[1]-1
		for i, y in ipairs(emptyLines.rows) do
			if i~=1 then
				local prevY = emptyLines.rows[i-1]
				if y-1 ~= prevY then
					error(string.format(
						"Failed detecting object groups: multiple disconnected empty rows at y %i and %i",
						prevY, y
					))
				end
			end
		end
	else
		if rHeight % 2 == 1 then
			error("Content height is uneven without air rows, can't neatly divide it in two")
		end
		cell.maxY = cell.minY + rHeight/2 -1
	end
	
	cell.width = cell.maxX - cell.minX + 1
	cell.height = cell.maxY - cell.minY + 1
	if not cell.extendX then
		cell.tileWidth = cell.width
	else
		cell.tileWidth = rWidth - cell.width
	end
	if not cell.extendY then
		cell.tileHeight = cell.height
	else
		cell.tileHeight = rHeight - cell.height
	end
	
	return cell
end

local function prepCell()
	local cell = cellSize()
	cell.patches = {}
	local mask = SelectionMask:new()
	for x=cell.minX, cell.maxX do
		for y=cell.minY, cell.maxY do
			mask:add(x,y)
			local obj = level.foreground[x][y]
			if obj then
				local posPatch = {
					propPatches = {},
					x = x,
					y = y,
				}
				for propId in obj:iterateProperties() do
					local baseValue = obj:getPropertyRaw(propId)
					local propPatch = {
						propId = propId,
						base = baseValue,
						dx = 0,
						dy = 0,
					}
					if cell.extendX then
						local otherX = x + cell.tileWidth
						local otherY = y
						local other = level.foreground[otherX][otherY]
						if not other then
							error(string.format(
								"Expected object at (%i,%i) to compare to object at (%i,%i)",
								otherX, otherY,
								x, y
							))
						end
						local otherValue = other:getPropertyRaw(propId)
						local type = PropData:getMappingType(propId)
						if type=="Hybrid" or type=="None" then
							--Numerical property, increase
							if baseValue~=otherValue then
								propPatch.dx = otherValue - baseValue
							end
						else
							-- No logical series to follow, verify they're the same
							if baseValue~=otherValue then
								error(string.format(
									"Expected objects at (%d,%d) and (%d,%d) to have non-numerical property %s be the same!",
									x, y,
									otherX, otherY,
									PropData:getName(propId)
								))
							end
						end
					end
					if cell.extendY then
						local otherX = x
						local otherY = y + cell.tileHeight
						local other = level.foreground[otherX][otherY]
						if not other then
							error(string.format(
								"Expected object at (%i,%i) to compare to object at (%i,%i)",
								otherX, otherY,
								x, y
							))
						end
						local otherValue = other:getPropertyRaw(propId)
						local type = PropData:getMappingType(propId)
						if type=="Hybrid" or type=="None" then
							--Numerical property, increase
							if baseValue~=otherValue then
								propPatch.dy = otherValue - baseValue
							end
						else
							-- No logical series to follow, verify they're the same
							if baseValue~=otherValue then
								error(string.format(
									"Expected objects at (%d,%d) and (%d,%d) to have non-numerical property %s be the same!",
									x, y,
									otherX, otherY,
									PropData:getName(propId)
								))
							end
						end
					end
					
					if propPatch.dx~=0 or propPatch.dy~=0 then
						table.insert(posPatch.propPatches, propPatch)
					end
				end
				
				if #posPatch.propPatches > 0 then
					table.insert(cell.patches, posPatch)
				end
			end
		end
	end
	-- use clipboard to handle path nodes
	cell.copy = Clipboard:new(level,mask)
	
	cell.pathPatches = {}
	
	for path in cell.copy.world.paths:iterate() do
		---@cast path Path
		local x, y = path.head.x + cell.minX - 1 , path.head.y + cell.minY - 1
		local pathPatch = {
			propPatches = {},
			x = x,
			y = y,
		}
		for propId in path:iterateProperties() do
			local baseValue = path:getPropertyRaw(propId)
			local propPatch = {
				propId = propId,
				base = baseValue,
				dx = 0,
				dy = 0,
			}
			if cell.extendX then
				local otherX = x + cell.tileWidth
				local otherY = y
				local other = level.pathNodes[otherX][otherY]
				if not other then
					error(string.format(
						"Expected path node at (%i,%i) to compare to path at (%i,%i)",
						otherX, otherY,
						x, y
					))
				end
				local otherValue = other.path:getPropertyRaw(propId)
				local type = PropData:getMappingType(propId)
				if type=="Hybrid" or type=="None" then
					--Numerical property, increase
					if baseValue~=otherValue then
						propPatch.dx = otherValue - baseValue
					end
				else
					-- No logical series to follow, verify they're the same
					if baseValue~=otherValue then
						error(string.format(
							"Expected paths at (%d,%d) and (%d,%d) to have non-numerical property %s be the same!",
							x, y,
							otherX, otherY,
							PropData:getName(propId)
						))
					end
				end
			end
			if cell.extendY then
				local otherX = x
				local otherY = y + cell.tileHeight
				local other = level.pathNodes[otherX][otherY]
				if not other then
					error(string.format(
						"Expected path node at (%i,%i) to compare to path at (%i,%i)",
						otherX, otherY,
						x, y
					))
				end
				local otherValue = other.path:getPropertyRaw(propId)
				local type = PropData:getMappingType(propId)
				if type=="Hybrid" or type=="None" then
					--Numerical property, increase
					if baseValue~=otherValue then
						propPatch.dy = otherValue - baseValue
					end
				else
					-- No logical series to follow, verify they're the same
					if baseValue~=otherValue then
						error(string.format(
							"Expected paths at (%d,%d) and (%d,%d) to have non-numerical property %s be the same!",
							x, y,
							otherX, otherY,
							PropData:getName(propId)
						))
					end
				end
			end
			
			if propPatch.dx~=0 or propPatch.dy~=0 then
				table.insert(pathPatch.propPatches, propPatch)
			end
		end
		
		if #pathPatch.propPatches > 0 then
			table.insert(cell.pathPatches, pathPatch)
		end
	end
	
	return cell
end


local function calcArea(cell)
	local startCellX = math.ceil(cell.minX/cell.tileWidth)
	local startCellY = math.ceil(cell.minY/cell.tileHeight)
	
	local offsetX = cell.minX - startCellX*cell.tileWidth
	local offsetY = cell.minY - startCellY*cell.tileHeight
	
	local minX, minY, maxX, maxY = selection.mask:getBounds()
	
	-- extra terms to allow placing cells into the area when their empty end parts don't fit
	local endXOver = cell.tileWidth - cell.width
	local endYOver = cell.tileHeight - cell.height
	
	return {
		startCellX = startCellX,
		startCellY = startCellY,
		tileOffsetX = offsetX,
		tileOffsetY = offsetY,
		minTileX = math.ceil((minX-offsetX)/cell.tileWidth),
		maxTileX = math.floor((maxX-offsetX+1+endXOver)/cell.tileWidth)-1,
		minTileY = math.ceil((minY-offsetY)/cell.tileHeight),
		maxTileY = math.floor((maxY-offsetY+1+endYOver)/cell.tileHeight)-1,
	}
	
end

local function build(cell, area)
	for tileX=area.minTileX, area.maxTileX do
		for tileY=area.minTileY, area.maxTileY do
			cell.copy:copy(
				cell.copy.world, level,
				0, 0,
				tileX*cell.tileWidth + area.tileOffsetX - 1,
				tileY*cell.tileHeight + area.tileOffsetY - 1
			)
			
			local dx = tileX - area.startCellX
			local dy = tileY - area.startCellY
			
			for _,posPatch in ipairs(cell.patches) do
				local x = posPatch.x + dx*cell.tileWidth
				local y = posPatch.y + dy*cell.tileHeight
				local obj = level.foreground[x][y]
				for _,propPatch in ipairs(posPatch.propPatches) do
					obj:setPropertyRaw(propPatch.propId, propPatch.base + propPatch.dx*dx + propPatch.dy*dy)
				end
			end
			for _,pathPatch in ipairs(cell.pathPatches) do
				local x = pathPatch.x + dx*cell.tileWidth
				local y = pathPatch.y + dy*cell.tileHeight
				local path = level.pathNodes[x][y].path
				for _,propPatch in ipairs(pathPatch.propPatches) do
					path:setPropertyRaw(propPatch.propId, propPatch.base + propPatch.dx*dx + propPatch.dy*dy)
				end
			end
		end
	end
end



assert(selection.mask, "Need selection to expand objects in")

local cell = prepCell()
local area = calcArea(cell)
print("cell")
printTable(cell)
print("area")
printTable(area)
build(cell, area)


