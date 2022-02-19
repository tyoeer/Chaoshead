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
	if NFS.getInfo(path) then
		return UD.class:new(path,code)
	else
		return nil, string.format("No userdata found for %q", code)
	end
end

UD.class = require(select(1,...)..".class")

return UD
