local DATA = Class()

function DATA:getRow(selector)
	if type(selector)=="number" then
		-- +1 to convert from 0-indexed levelhead ID's to 1-indexed Lua lists
		-- empty table so indexing a value that isn't set returns nil and not error
		local out = self.data[selector+1]
		if out then
			return out
		else
			print("ID not found: "..selector)
			return {}
		end
	elseif type(selector)=="string" then
		for i,v in ipairs(self.data) do
			if v[self.headers.name] == selector then
				return v
			end
		end
		
		print("Selector not found: "..selector)
		return {}
	else
		error(selector.." is invalid type: "..type(selector))
	end
end


function DATA:getID(selector)
	return self:getRow(selector)[self.headers.id] or
		(type(selector)=="number" and selector or "$UnknownId")
end

function DATA:getAllIDs(name)
	name = name:lower():gsub(" ","")
	local out = {}
	for i,v in ipairs(self.data) do
		if v[self.headers.name]:lower():gsub(" ","") == name then
			table.insert(out, v[self.headers.id])
		end
	end
	return out
end

function DATA:getName(selector)
	return self:getRow(selector)[self.headers.name] or "$UnknownName"
end


return DATA
