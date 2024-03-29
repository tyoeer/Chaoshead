local Csv = require("utils.csv")
local P = require("levelhead.data.properties")

---@class LHElementsData : LHData
---@field super LHData
local E = Class(require("levelhead.data.base"))

function E:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = Csv.parseString(love.filesystem.read("data/levelElements.tsv"),"\t")
	self.N_INHERITENCE_CHECKS = 20
	--parse headers
	self.headers = {}
	for _, header in ipairs(rawHeaders) do
		local raw = self:reduceSelector(header)
		if raw:match("^name$") then
			self.headers.name = header
		elseif raw:match("^iddecimal$") then
			self.headers.id = header
		elseif raw:match("width") then
			self.headers.width = header
		elseif raw:match("height") then
			self.headers.height = header
		elseif raw:match("^parent") then
			self.headers.parent = header
		elseif raw:match("^properties") then
			self.headers.properties = header
		elseif raw:match("^layer") then
			self.headers.layer = header
		end
	end
end

---@return integer|"$UnknownWidth"
function E:getWidth(selector)
	return self:getRow(selector)[self.headers.width] or "$UnknownWidth"
end

---@return integer|"$UnknownHeight"
function E:getHeight(selector)
	return self:getRow(selector)[self.headers.height] or "$UnknownHeight"
end

function E:getLayer(selector)
	return self:getRow(selector)[self.headers.layer] or "$UnknownLayer"
end

function E:getSize(selector)
	local r = self:getRow(selector)
	return r[self.headers.width] or "$UnknownWidth", r[self.headers.height] or "$UnknownHeight"
end


function E:getParent(selector)
	return self:getRow(selector)[self.headers.parent] or "$UnknownParent"
end
-- Keeps getting the parent until the end
function E:getRootParentId(selector)
	local row = self:getRow(selector)
	for _=1,self.N_INHERITENCE_CHECKS,1 do
		if row[self.headers.parent] and row[self.headers.parent]~="No" then
			row = self:getRow(row[self.headers.parent])
		else
			break
		end
	end
	return row[self.headers.id]
end

--uses reduced selectors
function E:buildPropertyIDMap(element)
	local out = {}
	for propId in self:iterateProperties(element) do
		out[self:reduceSelector(P:getName(propId))] = propId
	end
	return out
end

--uses reduced propertySelector
-- returns nil on unknown properties data instead of a $ error string
function E:getPropertyID(elementSelector,propertySelector)
	local row = self:getRow(elementSelector)
	if not row.propertyIDMap then
		if row[self.headers.properties]==nil then
			return nil
		end
		row.propertyIDMap = self:buildPropertyIDMap(elementSelector)
	end
	return row.propertyIDMap[self:reduceSelector(propertySelector)]
end

function E:hasProperties(selector)
	local start = selector
	for _=1,self.N_INHERITENCE_CHECKS,1 do
		local r = self:getRow(selector)
		local base = r[self.headers.properties]
		
		if base==nil then return "$UnknownProperties" end
		if base=="None" then return false end
		if base=="Inherit" then
			local p = r[self.headers.parent]
			if p==nil then
				return "$UnknownProperties"
			end
			selector = p
		else
			return true
		end
	end
	error(string.format("Failed to get property status of %q (start: %q), parent lookup took >%d checks, it's probably recursing.",selector,start,self.N_INHERITENCE_CHECKS))
end

--uses reduced propertySelector
-- returns nil on unknown properties data instead of a $ error string
function E:getPropertyDefault(elementSelector, targetPropId)
	for propId, default in self:iterateProperties(elementSelector) do
		if propId==targetPropId then
			return default or P:getCommonDefault(targetPropId)
		end
	end
	return nil
end

---Iterates over the property ID and an optional default
function E:iterateProperties(selector)
	local start = selector
	for _=1,self.N_INHERITENCE_CHECKS,1 do
		local r = self:getRow(selector)
		local base = r[self.headers.properties]
		
		if base==nil then
			error(string.format("Can't iterate unknown properties of %q (start: %q).",selector,start))
		end
		if base=="None" then
			--thise object has no properties
			--return a function that returns nil
			return function() end
		end
		if base=="Inherit" then
			local p = r[self.headers.parent]
			if p==nil then
				error(string.format("Can't iterate properties of %q (start: %q) due to unknown parents.",selector,start))
			end
			selector = p
		else
			--if there's only 1 id, the csv loader converts it into a number, which can't be iterated
			--this is a quick hack
			if type(base)=="number" then base = tostring(base) end
			--wrap string:gmatch() to tonumber() everything
			local f,s,v = base:gmatch("(%d+):?(%d*)")
			return function(_s,propId)
				local default
				propId, default = f() --f(s,propId) apparently not needed
				return propId==nil and nil or tonumber(propId), default==nil and nil or tonumber(default) 
			end, s, v
		end
	end
	error(string.format("Failed to get property status of %q (start: %q), parent lookup took >%d checks, it's probably recursing.",selector,start,self.N_INHERITENCE_CHECKS))
end


return E:new()
