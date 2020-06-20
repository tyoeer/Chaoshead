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
	for _,v in ipairs(self.raw.workshop.my_creations) do
		local data = self.raw.workshop.my_workshop[v]
		table.insert(out,{
			name = require("levelhead.misc").parseLevelName(data.nameparts),
			id = v,
			iconName = data.icon,
		})
	end
	return out
end

-- simple getters

function D:getLookupCode()
	return self.lookupCode
end

return D
