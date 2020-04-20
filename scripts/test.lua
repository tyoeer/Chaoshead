local O = require("levelhead.objects.base")

for i=10,15,1 do
	level:addObject(O:new(1),i,i)
	if i~=3 then
		level:addObject(O:new(1),6-i,i)
	end
end
