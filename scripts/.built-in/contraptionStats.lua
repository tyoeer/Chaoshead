--[[

Collects stats about relays/channels/rifts.

]]

local P = require("levelhead.data.properties")

-- init

local nRelays = 0
local nRifts = 0

local channels = {
	None={
		from = 0,
		to = 0,
		dq = "None"
	}
}
local riftIds = {
	None={
		from = 0,
		to = 0,
		dq = "None"
	}
}

for i=0, P:getMax("Sending Channel") do
	channels[i] = {
		from = 0,
		to = 0,
		-- dq = nil
		
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
		-- dq = nil
	}
end

local reqs = {}
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
	if obj:isElement("Rift") or obj:isElement("2x2 Rift") or obj:isElement("3x3 Rift") then
		nRifts = nRifts + 1
	end
	if obj:isElement("Relay") then
		nRelays = nRelays + 1
	end
end

for path in level.paths:iterate() do
	addThing(path)
end

-- Calculate DQs + channel timings

local dqList = {
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
local channelDqCounts = {}
local riftIDDqCounts = {}
for _,v in ipairs(dqList) do
	channelDqCounts[v] = 0
	riftIDDqCounts[v] = 0
end

local function getDQ(of)
	-- The amount of objects that send to this channel/rift id
	local t = of.to
	-- The amount of objects that receive from this channel/rift id
	local f = of.from
	if t==0 and f==0 then
		return "Unused"
	elseif t==0 and f>0 then
		return "0>X"
	elseif t>0 and f==0 then
		return "X>0"
	elseif t==1 and f==1 then
		return "1>1"
	elseif t==1 and f>1 then
		return "1>N"
	elseif t>1 and f==1 then
		return "N>1"
	elseif t>1 and f>1 then
		return "N>N"
	end
end


for i=0, P:getMax("Sending Channel") do
	local dq = getDQ(channels[i])
	channels[i].dq = dq
	channelDqCounts[dq] = channelDqCounts[dq] + 1
	
	if dq~="Unused" and dq~="0>X" and dq ~="X>0" then
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
	local dq = getDQ(riftIds[i])
	riftIds[i].dq = dq
	riftIDDqCounts[dq] = riftIDDqCounts[dq] + 1
end

-- Objects by DQ

local dqAndNoneList = {"None"}
for _,dq in ipairs(dqList) do
	table.insert(dqAndNoneList, dq)
end

local objectsByDq = {}

for _,v in ipairs(dqAndNoneList) do
	objectsByDq[v] = {}
	for _,vv in ipairs(dqAndNoneList) do
		objectsByDq[v][vv] = {
			relays = 0,
			rifts = 0,
		}
	end
end

for obj in level.objects:iterate() do
	if obj:isElement("Relay") then
		local from = obj:getReceivingChannel()
		local to = obj:getSendingChannel()
		objectsByDq[channels[from].dq][channels[to].dq].relays =
		objectsByDq[channels[from].dq][channels[to].dq].relays + 1
	end
	if obj:isElement("Rift") or obj:isElement("2x2 Rift") or obj:isElement("3x3 Rift") then
		local from = obj:getRiftID()
		local to = obj:getDestinationRiftID()
		objectsByDq[riftIds[from].dq][riftIds[to].dq].rifts =
		objectsByDq[riftIds[from].dq][riftIds[to].dq].rifts + 1
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

local function outputDq(l)
	for _,dq in ipairs(dqList) do
		o("- %s: %i", dq, l[dq])
	end
end
local function outputObjectByDq(field)
	for _,fromDq in ipairs(dqAndNoneList) do
		for _,toDq in ipairs(dqAndNoneList) do
			local n = objectsByDq[fromDq][toDq][field]
			if n~=0 then
				o("- %s -> %s: %i",fromDq,toDq,n)
			end
		end
	end
end

o("Total relays: %i", nRelays)
o("Total channels: %i", 1000-channelDqCounts.Unused)
o("Total rifts: %i", nRifts)
o("Total rift IDs: %i", 1000-riftIDDqCounts.Unused)
o("\nSwitch Requirements counts:")
	o("- any1: %i", reqs["Any Active"])
	o("- all1:  %i", reqs["All Active"])
	o("- one1: %i", reqs["One Active"])
	o("- any0: %i", reqs["Any Inactive"])
	o("- all0:  %i", reqs["All Inactive"])
	o("- one0: %i", reqs["One Inactive"])
o("\nChannels by degree quantifier:")
outputDq(channelDqCounts)
o("\nChannel timings:\n  (only counted channels with both senders and receivers)")
	o("- Immediate: %i", cdTypes.fast)
	o("- Delayed: %i", cdTypes.delay)
	o("- Mixed/complicated: %i", cdTypes.complex)
o("\nRelays by channel DQs:")
outputObjectByDq("relays")
o("\nRift IDs by degree qunatifier:")
outputDq(riftIDDqCounts)
o("\nRifts by rift ID DQs:")
outputObjectByDq("rifts")


local out = table.concat(out,"\n")

MainUI:popup(out)