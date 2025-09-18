--[[

Sets the contents of every foreground object in the selection to the level element of the object above it.

]]--

if not selection then
	error("No selection!")
end

for obj in selection.contents.foreground:iterate() do
	local x, y = obj.x, obj.y
	local above = level.foreground[x][y-1]
	if not above then
		above = level.background[x][y-1]
	end
	if above then
		obj:setContents(above.id)
	end
end