--[[

Deselects empty tiles

]]--

if not selection then
	error("No selection!")
end

for tile in selection.mask.tiles:iterate() do
	local x, y = tile.x, tile.y
	local has = false
	for layer,enabled in pairs(selection.mask.layers) do
		if enabled then
			has = level[layer][x][y] and true or false
		end
		if has then break end
	end
	if not has then
		selection.mask:remove(x,y)
	end
end