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
	local file = NFS.newFile(require("levelhead.misc").getUserDataPath()..code..dataFilePath)
	file:open("r")
	local data = file:read()
	file:close()
	return UD.class:new(data,code)
end

UD.class = require(select(1,...)..".class")

return UD
