--[[

Select 2 instances of the group of objects you want to expand.
- You can leave empty space between the groups
- The groups can be single tiles
- The groups have to be rectangular, but can be any size you want
- If you are expanding both horizontally and vertically, the bottom-right group in the 2x2 set of object groups you would expect get ignored and is optional

Select the area around the groups of objects you want to expand the groups into.
- You have to select the whole rectangle to prevent issues with a forgotten part of the selection being somewhere else
- The expansion area gets rounded to the size of your object group, and nothing will be placed outside the selection
- You can expand in all 4 direction

Run this script.
- Properties are NOT yet expanded

]]

local level = level
---@cast level Level

local Clipboard = require("tools.clipboard")
local SelectionMask = require("tools.selection.mask")

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

local function findEmptyLines(region)
	local firstEmptyColumn
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
			firstEmptyColumn = x
			break
		end
	end
	
	local firstEmptyRow
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
			firstEmptyRow = y
			break
		end
	end
	
	return {
		row=firstEmptyRow,
		column=firstEmptyColumn,
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
	elseif emptyLines.column then
		cell.maxX = emptyLines.column-1
	else
		if rWidth % 2 == 1 then
			error("Content width is uneven without air columns, can't neatly divide it in two")
		end
		cell.maxX = cell.minX + rWidth/2 -1
	end
	
	if not cell.extendY then
		cell.maxY = region.maxY
	elseif emptyLines.row then
		cell.maxY = emptyLines.row-1
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
		end
	end
	-- use clipboard to handle path nodes
	cell.copy = Clipboard:new(level,mask)
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


