local csv = require("utils.csv")
local E = Class(require("levelhead.data.base"))

function E:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/levelElements.tsv"),"\t")
	
	--parse headers
	self.headers = {}
	for i,v in ipairs(rawHeaders) do
		local raw = v:gsub("%W",""):lower()
		if raw:match("^name$") then
			self.headers.name = v
		elseif raw:match("^iddecimal$") then
			self.headers.id = v
		elseif raw:match("width") then
			self.headers.width = v
		elseif raw:match("height") then
			self.headers.height = v
		elseif raw:match("^parentid") then
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


function E:hasProperties(selector)
	for _=1,20,1 do
		local r = self:getRow(selector)
		local base = r[self.headers.properties]
		
		if base==nil then return "$UnknownProperties" end
		if base=="None" then return false end
		if base=="Inherit" then
			selector = r[self.headers.parent]
		else
			return true
		end
	end
	error(string.format("Failed to get property status of %q, parent lookup took >20 checks, it's probably recursing.",selector))
end

--WARNING: iterated properties will be strings, because that makes iteration possible with string.gmatch. they should be tonumber()ed manually
function E:iterateProperties(selector)
	for _=1,20,1 do
		local r = self:getRow(selector)
		local base = r[self.headers.properties]
		
		if base==nil then
			error(string.format("Can't iterate unknown properties of %q.",selector))
		end
		if base=="None" then return false end
		if base=="Inherit" then
			selector = r[self.headers.parent]
		else
			return base:gmatch("(%d+)")
		end
	end
	error(string.format("Failed to get property status of %q, parent lookup took >20 checks, it's probably recursing.",selector))
end


return E:new()
