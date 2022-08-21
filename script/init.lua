local S = {}

S.folder = "scripts/"

if not love.filesystem.getRealDirectory(S.folder) ~= love.filesystem.getSaveDirectory() then
	love.filesystem.createDirectory(S.folder)
end

function S.errorHandler(message)
	message = tostring(message)
	--part of snippet yoinked from default löve error handling
	local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
	print(fullTrace)
	--cut of the part of the trace that goes into the script
	--Match both type of slashes because of https://github.com/tomblind/local-lua-debugger-vscode/issues/69
	local index = fullTrace:find("%s+%[C%]: in function 'xpcall'%s+script[\\/][a-zA-Z/\\]+.lua:%d+:")
	local trace = fullTrace:sub(1,index-1)
	--trace = fullTrace
	return {message, trace}
end

function S.runDangerously(path, level, selection)
	local scriptText = love.filesystem.read(path)
	local script, err = loadstring(scriptText)
	if not script then
		return false, "Error loading script at "..path..":\n"..err
	end
	--provide the level as a global
	local oldLevel = _G.level
	local oldSelection = _G.selection
	_G.level = level
	_G.selection = selection
	
	local success, errInfo = xpcall(script, S.errorHandler)
	
	level = _G.level
	selection = _G.selection
	_G.level = oldLevel
	_G.selection = oldSelection
	if success then
		return level, selection
	else
		return false, "Error running script at "..path..":\n"..errInfo[1], errInfo[2]
	end
end

return S
