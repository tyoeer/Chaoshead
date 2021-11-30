local JSON = require("libs.json")
local NFS = require("libs.nativefs")

local DataFile = Class("DataFile")

function DataFile:initialize(fullPath)
	local raw, err = NFS.read(fullPath)
	if not raw then
		error(string.format("Error reading file at &q: %s",fullPath,err))
	end
	local jsonData, mystery, hash = raw:match("([^\r\n]+)[\r\n]([^\r\n]+)[\r\n]([^\r\n]+)")
	self.raw = require("libs.json").decode(jsonData)
	self.mystery = mystery
	self.hash = hash
end

return DataFile
