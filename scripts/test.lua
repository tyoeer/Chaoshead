local O = require("levelhead.objects.base")
local P = require("levelhead.objects.propertiesBase")

--cross
for i=11,15,1 do
	level:placeEnvironment(i,i)
	level:placeEnvironment(26-i,i)
end

--relays
for i=1,level.width,1 do
	local o = P:new("Relay")
	o:setSendingChannel(i)
	o:setReceivingChannel(i-1)
	--o:setSwitchRequirements(??)
	level:addObject(o, i,1)
end

--conveyors
for i=2,level.width-1,1 do
	local o = level:placeToeSlider(i,27)
	o:setDirection(0)
	o:setSpeed(700)
end

--Pitch test 51 55
local o = level:placeBoombox(2,2)
o:setPropertyRaw(51,0)
o:setInstrument(0)--bass
local o = level:placeBoombox(2,3)
o:setPropertyRaw(55,0)
o:setInstrument(0)--bass
local o = level:placeBoombox(3,2)
o:setPropertyRaw(51,0)
o:setInstrument(1)--melody
local o = level:placeBoombox(3,3)
o:setPropertyRaw(55,0)
o:setInstrument(1)--melody
