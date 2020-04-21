local LHS = {}

function LHS:serializeForeground(level)
	--init
	local s = {}
	self.rawContentEntries.singleForeground = s
	s.entries = {}
	--[[local r = {}
	self.rawContentEntries.foregroundRows = r
	r.entries = {}
	local c = {}
	self.rawContentEntries.foregroundColumns = c
	c.entries = {}]]--
	
	--process
	local idMap = {}
	
	for y=1, level.height, 1 do
		for x=1, level.width, 1 do
			local o = level.foreground[x][y]
			if o then
				if not idMap[o.id] then
					local entry = {}
					entry.id = o.id
					entry.objects = {}
					s.entries[#s.entries+1] = entry
					idMap[o.id] = entry
				end
				table.insert(idMap[o.id].objects,{
					x = o.x-1,
					y = level.height - o.y
				})
			end
		end
	end
	
	--finalize
	for _,v in ipairs(s.entries) do
		v.amount = #v.objects
	end
	s.nEntries = #s.entries
	--[[r.nEntries = #s.entries
	c.nEntries = #s.entries]]--
end

function LHS:serializeAll(level)
	self.rawContentEntries = {}
	self:serializeForeground(level)
end

return LHS
