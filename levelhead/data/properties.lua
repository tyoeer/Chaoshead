local csv = require("utils.csv")
local M = require("levelhead.data.music"):new()

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
		elseif raw:match("min") then
			self.headers.min = v
		elseif raw:match("max") then
			self.headers.max = v
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
	return self:getRow(selector)[self.headers.saveFormat] or "$UnknownSaveFormat"
end

function P:getMappingType(selector)
	return self:getRow(selector)[self.headers.mappingType] or "$UnknownMappingType"
end

function P:getMin(selector)
	return self:getRow(selector)[self.headers.min] or "$UnknownMinimum"
end

function P:getMax(selector)
	return self:getRow(selector)[self.headers.min] or "$UnknownMaximum"
end

function P:mappingToValue(selector, mapping)
	local p = self:getRow(selector)
	
	local mappingType = p[self.headers.mappingType]
	if mappingType=="None" then
		return tonumber(mappnig)
	elseif mappingType=="Simple" or mappingType=="Hybrid" then
		for i=-1,SIMPLE_MAPPING_SIZE,1 do
			if mapping == p[self.headers.map[i]] then
				return i
			end
		end
	elseif mappingType=="Music" then
		return M:getID(mapping)
	else
		print(selector.." has unknown mapping!")
		return "$UnknownMapping"
	end
	
	error("Illegal mapping value for "..selector..": "..tostring(mapping).." ("..type(mapping)..")")
end

function P:valueToMapping(selector, value)
	local p = self:getRow(selector)
	
	if type(value)~="number" then
		print("Illegal value: "..selector.." :-: "..tostring(value))
		return "$IllegalValue: "..tostring(value)
	end
	
	local min, max = p[self.headers.min], p[self.headers.max]
	if not min or not max then
		print("Property range undefined: "..selector.." :-: "..tostring(min).." - "..tostring("max"))
		return "$RangeUndefined"
	end
	if value < min or value > max then
		return "$OutOfBOunds"
	end
	
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
	elseif mappingType=="Music" then
		return M:getName(value)
	else
		print("Illegal mapping type: "..selector.." :-: "..mappingType)
		return "$UnknownMapping"
	end
end

return P
