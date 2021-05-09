local csv = require("utils.csv")
local L = Class(require("levelhead.data.base"))

function L:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/propertyLists.tsv"),"\t")
	
	--parse headers
	self.headers = {}
	for _,v in ipairs(rawHeaders) do
		local raw = self:reduceSelector(v)
		if raw:match("^value") then
			self.headers.value = v
		end
	end
end

function L:valueToMapping(list, value)
	return self.data[value+1][list]
end

--the mapping gets reduced like a selector
function L:mappingToValue(list, mapping)
	local check = self:reduceSelector(mapping)
	for i=1,#self.data,1 do
		if self:reduceSelector(self.data[i][list]) == check then
			return i-1
		end
	end
	error("Illegal mapping for property list "..list..": "..tostring(mapping).." ("..type(mapping)..")")
end

return L:new()
