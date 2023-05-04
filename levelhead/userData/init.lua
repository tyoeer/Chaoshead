local NFS = require("libs.nativefs")

local UD = {}

local dataFilePath = "/save_data"

function UD.getUserCodes()
	local items = NFS.getDirectoryItemsInfo(require("levelhead.misc").getUserDataPath())
	local out = {}
	for _,v in ipairs(items) do
		if v.type=="directory" then
			table.insert(out,v.name)
		end
	end
	return out
end

function UD.getUserData(code)
	local path = require("levelhead.misc").getUserDataPath()..code..dataFilePath
	local info = NFS.getInfo(path)
	if info and info.type=="file" then
		return UD.class:new(path,code)
	elseif info then
		return nil, string.format("Invalid userdata found for %q: save_data is a %s", code, info.type)
	else
		return nil, string.format("No userdata found for %q", code)
	end
end

UD.class = require(select(1,...)..".class")

return UD
