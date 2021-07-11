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
	--[[if love.system.getOS()=="Windows" then
		-- /a:d display directories
		-- /b don't show metadata
		local listCmd = "dir /a:d /b"
		local cdCmd = "cd \""..require("levelhead.misc").getUserDataPath().."\""
		local cmd = cdCmd.." && "..listCmd
		
		local cli = io.popen(cmd)
		local list = cli:read("*all")
		cli:close()
		
		local out = {}
		for entry in list:gmatch("(%w+)") do
			table.insert(out,entry)
		end
		return out
	else
		error("You're using Chaoshead on a non-windows system.\nI didn't think this would happen, because Levelhead is Windows only (as of the time of this writing).\nPlease get in touch so we can add support for your OS.")
	end]]--
end

function UD.getUserData(code)
	local file = io.open(require("levelhead.misc").getUserDataPath()..code..dataFilePath,"rb")
	local data = file:read("*a")
	file:close()
	return UD.class:new(data,code)
end

UD.class = require(select(1,...)..".class")

return UD
