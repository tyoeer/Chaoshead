local O = require("levelhead.objects.base")
local P = require("levelhead.objects.propertiesBase")
local L = require("levelhead.level")



local dirs = {"up","down","right","left"}
local dx = {
	up = 0,
	down = 0,
	right = 1,
	left = -1,
}
local dy = {
	up = -1,
	down = 1,
	left = 0,
	right = 0,
}

local nextFreeChannel = 0
local function calloc()
	nextFreeChannel = nextFreeChannel + 1
	return nextFreeChannel - 1
end

--directional delay testing. 123 relays: Result:
--Up: ~2 sec. delay
--left ~2 sec delay
--Down: No delay
--Right: No delay
if false then
	level = L:new(255,255)
	local startC = calloc()
	local lastC = {
		up = startC,
		down = startC,
		left = startC,
		right  = startC,
	}

	local startX = 256/2
	local startY = 256/2

	local counter = 0
	for i=2, 256/2-4, 1 do
		counter = counter + 1
		for _,dir in ipairs(dirs) do
			local r = level:placeRelay(startX + i * dx[dir], startY + i*dy[dir])
			r:setSwitchRequirements("Any Active")
			r:setReceivingChannel(lastC[dir])
			lastC[dir] = calloc()
			r:setSendingChannel(lastC[dir])
		end
	end

	level:placeFalltroughLedge(startX,startY)
	level:placePressureSwitch(startX,startY+1):setSendingChannel(startC)

	for _,dir in ipairs(dirs) do
		local x = startX + 2*dx[dir] + (dx[dir]==0 and 1 or 0)
		local y = startY + 2*dy[dir] + (dy[dir]==0 and 1 or 0)
		print(x,y)
		local h = level:placeHardlight(x,y)
		h:setSwitchRequirements("Any Active")
		h:setReceivingChannel(lastC[dir])
	end

	print(counter)
end

--[[
	Warning: this one will crash at loading with a 255x255 level size
	
	execution order testing:
	A:     B:
	1 3 or 1 2
	2 4    3 4
	
	Result: Order A takes some time, while B is instant
	Conclusion: the execution order is B
]]--
if false then
	level = L:new(40,40)
	local s = math.floor(level.width/2)
	local start,final
	--A
	start = calloc()
	final = start
	for i=1,s,1 do
		for j=1,s,1 do
			local r = level:placeRelay(i,j)
			r:setReceivingChannel(final)
			final = calloc()
			r:setSendingChannel(final)
		end
	end
	level:placePressureSwitch(1,s+3):setSendingChannel(start)
	level:placeHardlight(2,s+3):setReceivingChannel(final)
	--B
	start = calloc()
	final = start
	for i=1,s,1 do
		for j=s+1,level.width,1 do
			local r = level:placeRelay(j,i)
			r:setReceivingChannel(final)
			final = calloc()
			r:setSendingChannel(final)
		end
	end
	level:placePressureSwitch(s+1,s+3):setSendingChannel(start)
	level:placeHardlight(s+2,s+3):setReceivingChannel(final)
end
