local S = {}

S.folder = "scripts/"

function S.runDangerously(path, level)
	local scriptText = love.filesystem.read(path)
	local f, err = loadstring(scriptText)
	if not f then
		error("Error loading script at "..path..": "..err)
	end
	--provide the level as a global
	local oldLevel = _G.level
	_G.level = level
	
	f()
	
	level = _G.level
	_G.level = oldLevel
	return level
end

return S
