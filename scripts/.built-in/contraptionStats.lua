--[[

Collects stats about relays/channels/rifts.

]]

local P = require("levelhead.data.properties")

-- init

local channels = {}
local riftIds = {}
local reqs = {}
local nRifts = 0
local nRelays = 0

for i=0, P:getMax("Sending Channel") do
	channels[i] = {
		from = 0,
		to = 0,
		
		frMin = math.huge,
		frMax = -math.huge,
		trMin = math.huge,
		trMax = -math.huge,
	}
end

for i=0, P:getMax("Rift ID") do
	riftIds[i] = {
		from = 0,
		to = 0,
	}
end

for i=P:getMin("Switch Requirements"), P:getMax("Switch Requirements") do
	reqs[P:valueToMapping("Switch Requirements",i)] = 0
end

-- collect

local function rPos(obj)
	return obj.y * level:getWidth() + obj.x
end

local function prop(thing,prop)
	if thing:hasProperty(prop) then
		local val = thing:getProperty(prop)
		if val~="None" then
			return val
		end
	end
end
local function addThing(thing)
	local from = prop(thing,"Receiving Channel")
	if from then
		channels[from].from = channels[from].from + 1
		if thing.x then
			local r = rPos(thing)
			channels[from].frMin = math.min(channels[from].frMin, r)
			channels[from].frMax = math.max(channels[from].frMax, r)
		end
	end
	
	local to = prop(thing,"Sending Channel")
	if to then
		channels[to].to = channels[to].to + 1
		if thing.x then
			local r = rPos(thing)
			channels[to].trMin = math.min(channels[to].trMin, r)
			channels[to].trMax = math.max(channels[to].trMax, r)
		end
	end
	
	local req = prop(thing,"Switch Requirements")
	if req then
		reqs[req] = reqs[req] + 1
	end
	
	local fromRift = prop(thing,"Rift ID")
	if fromRift then
		riftIds[fromRift].from = riftIds[fromRift].from + 1
	end
	
	local toRift = prop(thing,"Destination Rift ID")
	if toRift then
		riftIds[toRift].to = riftIds[toRift].to + 1
	end
end

for obj in level.objects:iterate() do
	if obj:hasProperties() then
		addThing(obj)
	end
	if obj:isElement("Rift") then
		nRifts = nRifts + 1
	end
	if obj:isElement("Relay") then
		nRelays = nRelays + 1
	end
end

for path in level.paths:iterate() do
	addThing(path)
end

local types = {
	"0>X",
	"X>0",
	"1>1",
	"1>N",
	"N>1",
	"N>N",
	"Unused",
}

local cdTypes = {
	delay = 0,
	complex = 0,
	fast = 0,
}
local cTypes = {}
local rTypes = {}
for _,v in ipairs(types) do
	cTypes[v] = 0
	rTypes[v] = 0
end


for i=0, P:getMax("Sending Channel") do
	local f = channels[i].from
	local t = channels[i].to
	local cType
	if f==0 and t==0 then
		cType = "Unused"
	elseif f==0 and t>0 then
		cType = "0>X"
	elseif f>0 and t==0 then
		cType = "X>0"
	elseif f==1 and t==1 then
		cType = "1>1"
	elseif f==1 and t>1 then
		cType = "1>N"
	elseif f>1 and t==1 then
		cType = "N>1"
	elseif f>1 and t>1 then
		cType = "N>N"
	end
	
	channels[i].type = cType
	cTypes[cType] = cTypes[cType] + 1
	
	if cType~="Unused" and cType~="0>X" and cType ~="X>0" then
		if channels[i].trMax < channels[i].frMin then
			cdTypes.fast = cdTypes.fast + 1
		elseif channels[i].frMax < channels[i].trMin then
			cdTypes.delay = cdTypes.delay + 1
		else
			cdTypes.complex = cdTypes.complex + 1
		end
	end
end

for i=0, P:getMax("Rift ID") do
	local f = riftIds[i].from
	local t = riftIds[i].to
	local cType
	if f==0 and t==0 then
		cType = "Unused"
	elseif f==0 and t>0 then
		cType = "0>X"
	elseif f>0 and t==0 then
		cType = "X>0"
	elseif f==1 and t==1 then
		cType = "1>1"
	elseif f==1 and t>1 then
		cType = "1>N"
	elseif f>1 and t==1 then
		cType = "N>1"
	elseif f>1 and t>1 then
		cType = "N>N"
	end
	
	riftIds[i].type = cType
	rTypes[cType] = rTypes[cType] + 1
end

local cross = {}

for _,v in ipairs(types) do
	cross[v] = {}
	for _,vv in ipairs(types) do
		cross[v][vv] = {
			relays = 0,
			rifts = 0,
		}
	end
end

for obj in level.objects:iterate() do
	if obj:isElement("Relay") then
		local from = obj:getReceivingChannel()
		local to = obj:getSendingChannel()
		cross[channels[from].type][channels[to].type].relays =
		cross[channels[from].type][channels[to].type].relays + 1
	end
	if obj:isElement("Rift") then
		local from = obj:getRiftID()
		local to = obj:getDestinationRiftID()
		cross[riftIds[from].type][riftIds[to].type].rifts =
		cross[riftIds[from].type][riftIds[to].type].rifts + 1
	end
end

-- output

local out = {}

local function o(s, ...)
	if select("#", ...)==0 then
		table.insert(out, s)
	else
		table.insert(out, string.format(s, ...))
	end
end

local function typeOut(l)
	for _,v in ipairs(types) do
		o("- %s: %i", v, l[v])
	end
end
local function crossOut(field)
	for _,v in ipairs(types) do
		for _,vv in ipairs(types) do
			local n = cross[v][vv][field]
			if n~=0 then
				o("- %s -> %s: %i",v,vv,n)
			end
		end
	end
end

o("Total Relays: %i", nRelays)
o("Total Channels: %i", 1000-cTypes.Unused)
o("Total Rifts: %i", nRifts)
o("Total Rift IDs: %i", 1000-rTypes.Unused)
o("\nSwitch Requirements:")
	o("- any1: %i", reqs["Any Active"])
	o("- all1:  %i", reqs["All Active"])
	o("- one1: %i", reqs["One Active"])
	o("- any0: %i", reqs["Any Inactive"])
	o("- all0:  %i", reqs["All Inactive"])
	o("- one0: %i", reqs["One Inactive"])
o("\nChannels:")
typeOut(cTypes)
	o("\n- Immediate: %i", cdTypes.fast)
	o("- Delayed: %i", cdTypes.delay)
	o("- Complicated: %i", cdTypes.complex)
o("\nRelays:")
crossOut("relays")
o("\nRift IDs:")
typeOut(rTypes)
o("\nRifts:")
crossOut("rifts")


local out = table.concat(out,"\n")

MainUI:popup(out)