local P = require("levelhead.data.properties")
local LHS = {}


local settingsList = {
	[0] = "music",
	"mode",
	"minimumPlayers",
	"playerSharePowerups",
	"weather",
	"language",
	"multiplayerRespawnStyle",
	"stopCameraAtLevelSides"
}
function LHS:serializeHeaders(level)
	local s = level.settings
	local h = self.rawHeaders
	
	h.prefix = s.prefix
	h.zone = s.zone
	h.campaignMarker = s.campaignMarker
	
	h.width = level:getWidth()
	h.height = level:getHeight()
	
	--title
	for k,v in pairs(s.title) do
		h.title[k] = v
	end
	
	h.settingsList.entries = {}
	for id, setting in pairs(settingsList) do
		local value = s[setting]
		if type(value)=="boolean" then
			value = value and 1 or 0
		end
		table.insert(h.settingsList.entries,{
			id = id,
			value = value,
		})
	end
	h.settingsList.amount = #h.settingsList.entries
	
end

function LHS:serializeObjects(level,layer)
	--init
	local s = {}
	self.rawContentEntries["single"..layer:sub(1,1):upper()..layer:sub(2)] = s
	s.entries = {}
	local r = {}
	self.rawContentEntries[layer.."Rows"] = r
	r.entries = {}
	local c = {}
	self.rawContentEntries[layer.."Columns"] = c
	c.entries = {}
	
	--state
	local idMap = {}
	local done = {}
	for x=level.left, level.right, 1 do
		done[x] = {}
	end
	
	--process
	for y=level.bottom, level.top, -1 do
		for x=level.left, level.right, 1 do
			local o = level[layer][x][y]
			if o and not done[x][y] then
				--check the max size of a possible row/column
				local rowSize = 1
				while rowSize + x <= level.right do
					local oo = level[layer][x+rowSize][y]
					if oo and oo.id==o.id and not done[x+rowSize][y]  then
						rowSize = rowSize + 1
					else
						break
					end
				end
				
				local colSize = 1
				while y - colSize >= level.top do
					local oo = level[layer][x][y-colSize]
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
						entry.subentries = {}
						table.insert(s.entries, entry)
						idMap[o.id] = entry
					end
					table.insert(idMap[o.id].subentries,{
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
		v.amount = #v.subentries
	end
	s.nEntries = #s.entries
	r.nEntries = #r.entries
	c.nEntries = #c.entries
end

function LHS:serializeProperties(level,pathIdMap)
	local c = {
		entries = {}
	}
	if pathIdMap then
		self.rawContentEntries.pathProperties = c
	else
		self.rawContentEntries.objectProperties = c
	end
	
	local singleLookup = {}
	local doubleLookup = {}
	
	--process
	local toIterate
	if pathIdMap then
		toIterate = level.paths
	else
		toIterate = level.objects
	end
	for thing in toIterate:iterate() do
		if thing.properties then
			for id,value in pairs(thing.properties) do
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
					if pathIdMap then
						table.insert(subentry.entries,pathIdMap[thing])
					else
						table.insert(subentry.entries,{
							x = level:worldToFileX(thing.x),
							y = level:worldToFileY(thing.y)
						})
					end
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

function LHS:serializeContainedObjects(level)
	--init
	local c = {
		entries = {}
	}
	self.rawContentEntries.containedObjects = c
	
	--state
	local idMap = {}
	
	--process
	for obj in level.objects:iterate() do
		if obj.contents then
			if not idMap[obj.id] then
				local entry = {}
				entry.id = obj.contents
				entry.subentries = {}
				table.insert(c.entries, entry)
				idMap[obj.contents] = entry
			end
			table.insert(idMap[obj.contents].subentries,{
				x = level:worldToFileX(obj.x),
				y = level:worldToFileY(obj.y)
			})
		end
	end
	
	--finalize
	for _,v in ipairs(c.entries) do
		v.amount = #v.subentries
	end
	c.nEntries = #c.entries
end

function LHS:serializePaths(level)
	local idMap = {}
	local c = {
		entries = {},
	}
	self.rawContentEntries.paths = c
	
	local idCounter = 0x0000
	for path in level.paths:iterate() do
		local entry = {
			id = idCounter,
			subentries = {}
		}
		idMap[path] = entry.id
		idCounter = idCounter + 1
		
		for n in path:iterateNodes() do
			table.insert(entry.subentries,{
				x = level:worldToFileX(n.x),
				y = level:worldToFileY(n.y),
			})
		end
		
		entry.amount = #entry.subentries
		table.insert(c.entries,entry)
	end
	
	c.nEntries = #c.entries
	return idMap
end


function LHS:serializeAll(level)
	self:serializeHeaders(level)
	self.rawContentEntries = {}
	self:serializeObjects(level,"foreground")
	self:serializeProperties(level)
	self:serializeContainedObjects(level)
	local idMap = self:serializePaths(level)
	self:serializeProperties(level,idMap)
	self:serializeObjects(level,"background")
end

return LHS
