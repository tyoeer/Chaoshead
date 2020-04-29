local DATA = Class()

function DATA:getRow(selector)
	if type(selector)=="number" then
		-- +1 to convert from 0-indexed levelhead ID's to 1-indexed Lua lists
		return self.data[selector+1]
	elseif type(selector)=="string" then
		for i,v in ipairs(self.data) do
			if v[self.headers.name] == selector then
				return v
			end
		end
	else
		error(selector.." is invalid type: "..type(selector))
	end
end


function DATA:getID(selector)
	return self:getRow(selector)[self.headers.id]
end

function DATA:getAllIDs(name)
	print(name)
	local out = {}
	for i,v in ipairs(self.data) do
		if v[self.headers.name] == name then
			table.insert(out, v[self.headers.id])
		end
	end
	return out
end

function DATA:getName(selector)
	return self:getRow(selector)[self.headers.name]
end


return DATA
