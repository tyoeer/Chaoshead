local LhMisc = require("levelhead.misc")

---@class UserData : DataFile
---@field super DataFile
---@field new fun(self, fullPath: string, lookupCode: string): self
local D = Class("UserData",require("levelhead.dataFile"))

---@param fullPath string
---@param lookupCode string
function D:initialize(fullPath,lookupCode)
	self.lookupCode = lookupCode
	D.super.initialize(self,fullPath)
end

-- complex getters

function D:getWorkshopLevels()
	local out = {}
	for _,id in ipairs(self.raw.workshop.my_creations) do
		local data = self.raw.workshop.my_workshop[id]
		table.insert(out,{
			name = LhMisc.parseLevelName(data.nameparts):gsub("$Unnamed Level", "$Unnamed Level".." ["..id.."]"),
			id = id,
			iconName = data.icon,
			path = LhMisc.getUserDataPath().. self.lookupCode .."/Stages/".. id ..".lhs",
		})
	end
	return out
end

-- simple getters

function D:getLookupCode()
	return self.lookupCode
end

return D
