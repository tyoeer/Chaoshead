---@alias Selector integer|string

---@class LHData : Class
---@field data table<number, table<string, unknown>>
---@field headers table<string, string>
local DATA = Class()

---@param selector Selector
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
		for _,row in ipairs(self.data) do
			if row[self.headers.name] == selector then
				return row
			end
		end
		
		print("Selector not found: "..selector)
		return {}
	else
		error(selector.." is invalid type: "..type(selector))
	end
end

function DATA:reduceSelector(selector)
	return selector:gsub("%W",""):lower()
end

---@param selector Selector
---@return integer|"$UnknownId"
function DATA:getID(selector)
	return self:getRow(selector)[self.headers.id] or
		(type(selector)=="number" and selector or "$UnknownId")
end

--uses reduced selectors
function DATA:getAllIDs(name)
	name = self:reduceSelector(name)
	local out = {}
	for _,row in ipairs(self.data) do
		if row[self.headers.name]:lower():gsub(" ","") == name then
			table.insert(out, row[self.headers.id])
		end
	end
	return out
end

function DATA:getName(selector)
	return self:getRow(selector)[self.headers.name] or "$UnknownName"
end

function DATA:getHighestID()
	return #self.data - 1
end

return DATA
