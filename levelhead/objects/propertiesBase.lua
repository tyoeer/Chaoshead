local P = require("levelhead.data.properties")

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
	if value==nil then
		error(string.format("Can't set property %q to nil!",id),2)
	end
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
		--prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,mapping)
			local exists = false
			local set = false
			for _,id in ipairs(P:getAllIDs(prop)) do
				exists = true
				if P:isValidMapping(id,mapping) then
					set = true
					self:setProperty(id, mapping)
				end
			end
			if not set then
				if exists then
					error("Mapping "..mapping.." is invalid for property "..prop)
				else
					error("Property "..prop.." doesn't exist")
				end
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
