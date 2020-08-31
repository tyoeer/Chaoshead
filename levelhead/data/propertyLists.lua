local csv = require("utils.csv")
local L = Class()

function L:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/propertyLists.tsv"),"\t")
	
	--parse headers
	self.headers = {}
	for _,v in ipairs(rawHeaders) do
		local raw = v:gsub("%W",""):lower()
		if raw:match("^value") then
			self.headers.value = v
		end
	end
end

function L:valueToMapping(list, value)
	return self.data[value+1][list]
end

function L:mappingToValue(list, mapping)
	local check = mapping:gsub("%W",""):lower()
	for i=1,#self.data,1 do
		if self.data[i][list]:gsub("%W",""):lower() == check then
			return i-1
		end
	end
	error("Illegal mapping for property list "..list..": "..tostring(mapping).." ("..type(mapping)..")")
end

return L:new()
