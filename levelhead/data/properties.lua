local csv = require("utils.csv")
local P = Class(require("levelhead.data.base"))

local SIMPLE_MAPPING_SIZE = 8

function P:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/properties.tsv"),"\t")

	--parse headers
	self.headers = {
		map = {}
	}
	for i,v in ipairs(rawHeaders) do
		local raw = v:lower():gsub("[^a-z0-9%-]","")
		if raw:match("saveformat") then
			self.headers.saveFormat = v
		elseif raw:match("name") then
			self.headers.name = v
		elseif raw:match("iddecimal") then
			self.headers.id = v
		elseif raw:match("mappingtype") then
			self.headers.mappingType = v
		else
			for i=-1,SIMPLE_MAPPING_SIZE,1 do
				if raw:match(string.depatternize("map"..tostring(i))) then
					self.headers.map[i] = v
				end
			end
		end
	end
end

function P:getSaveFormat(selector)
	return self:getRow(selector)[self.headers.saveFormat]
end

function P:getMappingType(selector)
	return self:getRow(selector)[self.headers.mappingType]
end

function P:mappingToValue(selector, mapping)
	if type(mapping)=="number" then
		return mapping
	end
	local p = self:getRow(selector)
	for i=-1,SIMPLE_MAPPING_SIZE,1 do
		if mapping == p[self.headers.map[i]] then
			return i
		end
	end
	error("Illegal mapping value for "..selector..": "..tostring(mapping).." ("..type(mapping)..")")
end

function P:valueToMapping(selector, value)
	local p = self:getRow(selector)
	local mappingType = p[self.headers.mappingType]
	if mappingType=="None" then
		return value
	elseif mappingType=="Simple" then
		return p[self.headers.map[value]]
	elseif mappingType=="Hybrid" then
		if value > SIMPLE_MAPPING_SIZE then
			return value
		end
		local m = p[self.headers.map[value]]
		if m=="-" then
			return value
		else
			return m
		end
	else
		error("Illegal mapping type: "..selector.." :-: "..mappingType)
	end
end

return P
