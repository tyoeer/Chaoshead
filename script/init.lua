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
	--since we're using a coroutine, we only have the part that goes into the script
	--cut of the part of the trace that goes into the script
	--Match both type of slashes because of https://github.com/tomblind/local-lua-debugger-vscode/issues/69
	-- local index = fullTrace:find("%s+%[C%]: in function 'xpcall'%s+script[\\/][a-zA-Z/\\]+.lua:%d+:")
	-- local trace = fullTrace:sub(1,index-1)
	return {message, fullTrace}
end

---@param into table
---@param env table which values to insert
---@param guide table? which keys to insert, used to handle nils, defaults to env
---@return table old the parts of the environment that were replaced
function S.insertEnv(into, env, guide)
	local old = {}
	for key,_ in pairs(guide or env) do
		old[key] = into[key]
		into[key] = env[key]
	end
	return old
end

---@param level Level
---@param selectionMask SelectionMask
---@param selectionContents SelectionContents
---@return table
function S.buildLevelEnv(level, selectionMask, selectionContents)
	return {
		level = level,
		selection = {
			mask = selectionMask,
			contents = selectionContents,
		},
		ScriptUi = {
			requestString = function(message)
				local resume = AsyncResume
				MainUI:getString("Message from the script:\n"..tostring(message), function(text)
					resume(text)
				end)
				return coroutine.yield()
			end,
		}
	}
end

--- @param fn function
--- @param env table
--- @param ... any
--- @return table changedEnv, ... function return values
function S.runWithMoreEnv(fn, env, ...)
	local oldGlobals = S.insertEnv(_G, env)
	local ret = {fn(...)}
	local changedEnv = S.insertEnv(_G, oldGlobals, env)
	return changedEnv, unpack(ret)
end

---@param path string
---@return false|function, string? errInfo
function S.loadScript(path)
	local scriptText, sizeOrError = love.filesystem.read(path)
	if scriptText==nil then
		return false, "Error reading script file at "..path..":\n"..tostring(sizeOrError)
	end
	local name = path:match("scripts?[/\\](.+)") or path
	local script, err = loadstring(scriptText, name)
	if not script then
		return false, "Error loading script at "..path..":\n"..err
	end
	return script
end

---Note that the callback can be called before this function has finished
---@param path string
---@param env table
---@param successCallback fun(env: table, path: string)
---@param errorCallback fun(errorMessage: string, errTrace: table, env: table)
---@return boolean success, string? errInfo
function S.runAsyncDangerously(path, env, successCallback, errorCallback)
	local script, errInfo = S.loadScript(path)
	if not script then
		return false, errInfo
	end
	
	local pscript = function()
		return xpcall(script, S.errorHandler)
	end
	
	local asyncScript = coroutine.create(pscript)
	local scriptEnv = env
	scriptEnv.AsyncResume = function(...)
		local changedEnv, coSUc, success, errInfo = S.runWithMoreEnv(function(...)
			return coroutine.resume(asyncScript, ...)
		end, scriptEnv, ...)
		scriptEnv = changedEnv
		if success==false then
			---@cast errInfo -nil
			errorCallback("Error running script at "..path..":\n"..errInfo[1], errInfo[2], scriptEnv)
			return
		end
		if coroutine.status(asyncScript)=="dead" then
			successCallback(scriptEnv, path)
		end
	end
	
	scriptEnv.AsyncResume()
	
	return true
end


return S
