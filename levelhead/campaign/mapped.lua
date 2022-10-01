local JM = Class("mapped")

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
				error("Source does not have field "..mapping.." to map to "..field,2)
			end
			self[field] = src[mapping]
		elseif type(mapping)=="table" then
			local val = src[mapping[1]]
			if not val then
				error("Source does not have field "..mapping[1].." to map to "..field,2)
			end
			if mapping.from then
				val = mapping.from(val)
			end
			self[field] = val
		else
			error("Mapping info for field "..field.." is invalid type "..type(mapping),2)
		end
	end
end

return JM