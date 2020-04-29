local P = require("levelhead.data.properties"):new()

local OBJ = Class(require("levelhead.objects.base"))

function OBJ:initialize(id)
	self.class.super.initialize(self,id)
	self.properties = {}
end

function OBJ:setPropertyRaw(id, value)
	self.properties[P:getID(id)] = value
end

function OBJ:getPropertyRaw(id)
	return self.properties[P:getID(id)]
end

function OBJ:__index(key)
	if key:match("set") then
		local prop = key:match("set(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,value)
			for _,id in ipairs(P:getAllIDs(prop)) do
				self:setPropertyRaw(id, value)
			end
		end
	elseif key:match("get") then
		local prop = key:match("get(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self)
			--LH doesn't set all the properties, so this is currently a bit broken
			return self:getPropertyRaw(P:getID(prop))
		end
	end
end

return OBJ
