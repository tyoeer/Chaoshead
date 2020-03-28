local P = require("levelhead.data.properties"):new()

local OBJ = Class(require("levelhead.objects.base"))

function OBJ:initialize(id)
	self.class.super.initialize(self,id)
	self.properties = {}
end

function OBJ:setPropertyRaw(id, value)
	self.properties[P:getName(id)] = value
end

function OBJ:getPropertyRaw(id)
	return self.properties[P:getName(id)]
end

return OBJ
