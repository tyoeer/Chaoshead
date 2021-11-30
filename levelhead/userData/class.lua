local D = Class("UserData",require("levelhead.dataFile"))

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
			name = require("levelhead.misc").parseLevelName(data.nameparts):gsub("$Unnamed Level", "$Unnamed Level".." ["..id.."]"),
			id = id,
			iconName = data.icon,
			path = require("levelhead.misc").getUserDataPath().. self.lookupCode .."/Stages/".. id ..".lhs",
		})
	end
	return out
end

-- simple getters

function D:getLookupCode()
	return self.lookupCode
end

return D
