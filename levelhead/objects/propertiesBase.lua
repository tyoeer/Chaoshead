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
		return function(value)
			self.properties[P:getID(prop)] = value
		end
	elseif key:match("get") then
		local prop = key:match("get(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function()
			return self.properties[P:getID(prop)]
		end
	end
end

return OBJ
