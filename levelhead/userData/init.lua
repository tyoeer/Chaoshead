local NFS = require("libs.nativefs")

local UD = {}

local dataFilePath = "/save_data"

---@return string[]
function UD.getUserCodes()
	local udp = require("levelhead.misc").getUserDataPath()
	if not udp then
		return {} -- no user codes
	end
	local items = NFS.getDirectoryItemsInfo(udp)
	local out = {}
	for _,v in ipairs(items) do
		if v.type=="directory" then
			table.insert(out,v.name)
		end
	end
	return out
end

---@param code string
---@return table?, string?
function UD.getUserData(code)
	local udp = require("levelhead.misc").getUserDataPath()
	if not udp then
		return nil, "No user data path available"
	end
	local path = udp..code..dataFilePath
	local info = NFS.getInfo(path)
	if info and info.type=="file" then
		local success, result = pcall(
			UD.class.new,
			UD.class,
			path,
			code
		)
		if success then
			return result
		else
			return nil, "Error parsing save_data:\n"..tostring(result)
		end
	elseif info then
		return nil, string.format("Invalid userdata found for %q: save_data is a %s", code, info.type)
	else
		return nil, string.format("No userdata found for %q", code)
	end
end

UD.class = require(select(1,...)..".class")

return UD
