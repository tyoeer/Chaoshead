local P = require("levelhead.data.properties")
local LHS = {}

function LHS:serializeForeground(level)
	--init
	local s = {}
	self.rawContentEntries.singleForeground = s
	s.entries = {}
	local r = {}
	self.rawContentEntries.foregroundRows = r
	r.entries = {}
	local c = {}
	self.rawContentEntries.foregroundColumns = c
	c.entries = {}
	
	--state
	local idMap = {}
	local done = {}
	for x=1, level.width, 1 do
		done[x] = {}
	end
	
	--process
	for y=level.height, 1, -1 do
		for x=1, level.width, 1 do
			local o = level.foreground[x][y]
			if o and not done[x][y] then
				--check the max size of a possible row/column
				local rowSize = 1
				while rowSize + x <= level.width do
					local oo = level.foreground[x+rowSize][y]
					if oo and oo.id==o.id and not done[x+rowSize][y]  then
						rowSize = rowSize + 1
					else
						break
					end
				end
				
				local colSize = 1
				while y - colSize >= 0 do
					local oo = level.foreground[x][y-colSize]
					if oo and oo.id==o.id and not done[x][y-colSize] then
						colSize = colSize + 1
					else
						break
					end
				end
				
				--select the biggest one, row on ties, single object when they're both 1
				if rowSize == 1 and colSize == 1 then
					--make it a single foreground object
					if not idMap[o.id] then
						local entry = {}
						entry.id = o.id
						entry.objects = {}
						table.insert(s.entries, entry)
						idMap[o.id] = entry
					end
					table.insert(idMap[o.id].objects,{
						x = level:worldToFileX(o.x),
						y = level:worldToFileY(o.y)
					})
					done[x][y] = true
				elseif rowSize >= colSize then
					local entry = {
						length = rowSize-1,
						id = o.id,
						x = level:worldToFileX(o.x),
						y = level:worldToFileY(o.y)
					}
					table.insert(r.entries, entry)
					for i=0, rowSize-1, 1 do
						done[x+i][y] = true
					end
				elseif colSize > rowSize then
					local entry = {
						length = colSize-1,
						id = o.id,
						x = level:worldToFileX(o.x),
						y = level:worldToFileY(o.y)
					}
					table.insert(c.entries, entry)
					for i=0, colSize-1, 1 do
						done[x][y-i] = true
					end
				else
					error("Col./row comparison went wrong: "..colSize.." c/r "..rowSize)
				end
			end
		end
	end
	
	--finalize
	for _,v in ipairs(s.entries) do
		v.amount = #v.objects
	end
	s.nEntries = #s.entries
	r.nEntries = #r.entries
	c.nEntries = #c.entries
end

function LHS:serializeObjectProperties(level)
	local c = {}
	self.rawContentEntries.objectProperties = c
	c.entries = {}
	
	local singleLookup = {}
	local doubleLookup = {}
	
	--process
	for obj in level.allObjects:iterate() do
		if obj.properties then
			for id,value in pairs(obj.properties) do
				local go = true
				if not singleLookup[id] then
					singleLookup[id] = {
						id = id,
						entries = {}
					}
					table.insert(c.entries, singleLookup[id])
					doubleLookup[id] = {}
				end
				local entry = singleLookup[id]
				
				local subentry
				if not doubleLookup[id][value] then
					--make sure the save format can handle this value
					--fail quietly because of aggressive property setting
					--this part can be removed once the property names of the an element no longer overlap
					--which they currently do because all elements share all properties (data needs to be collected)
					local f = P:getSaveFormat(id)
					if f=="A" and (value<0 or value>255) then
						go = false
					elseif f=="B" and (value<-32768 or value>32767) then
						go = false
					-- no C because floats are huge, and can thus save everything
					elseif f=="D" and (value<-128 or value>127) then
						go = false
					end
					
					if go then
						subentry = {
							value = value,
							entries = {}
						}
						doubleLookup[id][value] = subentry
						table.insert(entry.entries,subentry)
					end
				else
					subentry = doubleLookup[id][value]
				end
				if go then
					table.insert(subentry.entries,{
						x = level:worldToFileX(obj.x),
						y = level:worldToFileY(obj.y)
					})
				end
			end
		end
	end
	
	--finalize
	for _,entry in ipairs(c.entries) do
		for _,subentry in ipairs(entry.entries) do
			subentry.amount = #subentry.entries
		end
		entry.amount = #entry.entries
	end
	c.nEntries = #c.entries
end

function LHS:serializeAll(level)
	self.rawContentEntries = {}
	self:serializeForeground(level)
	self:serializeObjectProperties(level)
end

return LHS
