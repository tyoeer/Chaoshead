local O = require("levelhead.objects.base")
local P = require("levelhead.objects.propertiesBase")

--cross
for i=11,15,1 do
	level:addObject(O:new(1),i,i)
	if i~=13 then
		level:addObject(O:new(1),26-i,i)
	end
end

--relays
for i=1,level.width,1 do
	local o = P:new(157)--relay
	o:setSendingChannel(i)
	o:setReceivingChannel(i-1)
	--o:setSwitchRequirements(??)
	level:addObject(o, i,1)
end
