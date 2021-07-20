local S = {}

S.folder = "scripts/"

if not love.filesystem.getInfo(S.folder) then
	love.filesystem.createDirectory(S.folder)
end

function S.runDangerously(path, level, selection)
	local scriptText = love.filesystem.read(path)
	local f, err = loadstring(scriptText)
	if not f then
		error("Error loading script at "..path..": "..err)
	end
	--provide the level as a global
	local oldLevel = _G.level
	local oldSelection = _G.selection
	_G.level = level
	_G.selection = selection
	
	f()
	
	level = _G.level
	selection = _G.selection
	_G.level = oldLevel
	_G.selection = oldSelection
	return level, selection
end

return S
