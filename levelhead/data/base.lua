local DATA = Class()

function DATA:getRow(selector)
	if type(selector)=="number" then
		-- +1 to convert from 0-indexed levelhead ID's to 1-indexed Lua lists
		return self.data[selector+1]
	elseif type(selector)=="string" then
		for i,v in ipairs(self.data) do
			if v["Name"] == selector then
				return v
			end
		end
	end
end


function DATA:getID(selector)
	return self:getRow(selector)[self.headers.id]
end

function DATA:getName(selector)
	return self:getRow(selector)[self.headers.name]
end


return DATA