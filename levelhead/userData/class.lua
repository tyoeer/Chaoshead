local D = Class("UserData")

function D:initialize(fileData,lookupCode)
	self.lookupCode = lookupCode
	local jsonData, mystery, hash = fileData:match("([^\r\n]+)[\r\n]([^\r\n]+)[\r\n]([^\r\n]+)")
	self.raw = require("libs.json").decode(jsonData)
	self.mystery = mystery
	self.hash = hash
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
