local JM = Class("Mapped")

function JM:initialize(...)
	self.mappings = {}
	for _,mapping in ipairs({...}) do
		self:extendMappings(mapping)
	end
end

function JM:extendMappings(extra)
	for field, mapping in pairs(extra) do
		self.mappings[field] = mapping
	end
end

function JM:fromMapped(src)
	for field, mapping in pairs(self.mappings) do
		if type(mapping)=="string" then
			if not src[mapping] then
				error("Source does not have field "..tostring(mapping).." to map to "..tostring(field), 2)
			end
			self[field] = src[mapping]
		elseif type(mapping)=="table" then
			local val = src[mapping[1]]
			if val==nil and not mapping.optional then
				error("Source does not have field "..tostring(mapping[1]).." to map to "..tostring(field), 2)
			end
			if mapping.from then
				val = mapping.from(val)
			end
			self[field] = val
		else
			error("Mapping info for field "..tostring(field).." is invalid type "..type(mapping), 2)
		end
	end
end

function JM:toMapped()
	local dst = {}
	for field, mapping in pairs(self.mappings) do
		if type(mapping)=="string" then
			if not self[field] then
				error("Self does not have field "..tostring(field).." to map to "..tostring(mapping), 2)
			end
			dst[mapping] = self[field]
		elseif type(mapping)=="table" then
			local val = self[field]
			if val==nil and not mapping.optional then
				error("Self does not have field "..tostring(field).." to map to "..tostring(mapping[1]), 2)
			end
			if mapping.to then
				val = mapping.to(val)
			end
			dst[mapping[1]] = val
		else
			error("Mapping info for field "..tostring(field).." is invalid type "..type(mapping), 2)
		end
	end
	return dst
end

local boolTo = function(val)
	return val and 1 or 0
end
local boolFrom = function(raw)
	return raw and raw>0.5 or false
end
function JM.mapBool(field, optional)
	if type(field)=="table" then
		error("Don't use OOP call!", 2)
	end
	if field==nil then
		error("Field is nil!", 2)
	end
	return {
		field,
		to = boolTo,
		from = boolFrom,
		optional = optional,
	}
end

return JM