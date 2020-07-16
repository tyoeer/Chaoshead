local P = require("levelhead.data.properties"):new()

local OBJ = Class(require("levelhead.objects.base"))

function OBJ:initialize(id)
	self.class.super.initialize(self,id)
	self.properties = {}
end

function OBJ:setPropertyRaw(id, value)
	self.properties[id] = value
end

function OBJ:getPropertyRaw(id)
	return self.properties[id]
end

function OBJ:setProperty(id, value)
	id = P:getID(id)
	self:setPropertyRaw(id,P:mappingToValue(id,value))
end

function OBJ:getProperty(id)
	id = P:getID(id)
	return P:valueToMapping(id,self:getPropertyRaw(id))
end

function OBJ:__index(key)
	if key:match("set") then
		local prop = key:match("set(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,mapping)
			local set = false
			for _,id in ipairs(P:getAllIDs(prop)) do
				if P:isValidMapping(id,mapping) then
					set = true
					self:setProperty(id, mapping)
				end
			end
			if not set then
				error("Mapping "..mapping.." is invalid for property "..property)
			end
		end
	elseif key:match("get") then
		local prop = key:match("get(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self)
			--LH doesn't set all the properties, so this is currently a bit broken
			return self:getProperty(prop)
		end
	end
end

return OBJ
