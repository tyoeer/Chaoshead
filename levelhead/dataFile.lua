local JSON = require("libs.json")
local NFS = require("libs.nativefs")

---@class DataFile : Class
---@field new fun(self, fullPath: string): self
local DataFile = Class("DataFile")

---@param fullPath string
function DataFile:initialize(fullPath)
	local raw, err = NFS.read(fullPath)
	if not raw then
		error(string.format("Error reading file at %q: %s",fullPath,err))
	end
	local jsonData, mystery, hash = raw:match("([^\r\n]+)[\r\n]([^\r\n]+)[\r\n]([^\r\n]+)")
	self.raw = JSON.decode(jsonData)
	self.mystery = mystery
	self.hash = hash
end

return DataFile
