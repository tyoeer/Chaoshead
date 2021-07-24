local csv = require("utils.csv")
local P = require("levelhead.data.properties")
local E = Class(require("levelhead.data.base"))

function E:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/levelElements.tsv"),"\t")
	self.N_INHERITENCE_CHECKS = 20
	--parse headers
	self.headers = {}
	for i,v in ipairs(rawHeaders) do
		local raw = self:reduceSelector(v)
		if raw:match("^name$") then
			self.headers.name = v
		elseif raw:match("^iddecimal$") then
			self.headers.id = v
		elseif raw:match("width") then
			self.headers.width = v
		elseif raw:match("height") then
			self.headers.height = v
		elseif raw:match("^parent") then
			self.headers.parent = v
		elseif raw:match("^properties") then
			self.headers.properties = v
		end
	end
end


function E:getWidth(selector)
	return self:getRow(selector)[self.headers.width] or "$UnknownWidth"
end

function E:getHeight(selector)
	return self:getRow(selector)[self.headers.height] or "$UnknownHeight"
end

function E:getSize(selector)
	local r = self:getRow(selector)
	return r[self.headers.width] or "$UnknownWidth", r[self.headers.height] or "$UnknownHeight"
end


function E:getParent(selector)
	return self:getRow(selector)[self.headers.parent] or "$UnknownParent"
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
			local f,s,v = base:gmatch("(%d+)")
			return function(s,v)
				v = f(s,v)
				return v==nil and nil or tonumber(v)
			end, s, v
		end
	end
	error(string.format("Failed to get property status of %q (start: %q), parent lookup took >%d checks, it's probably recursing.",selector,start,self.N_INHERITENCE_CHECKS))
end


return E:new()
