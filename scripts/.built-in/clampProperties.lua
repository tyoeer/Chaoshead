--[[

Clamps all properties back into their valid range.
Doesn't care if the objects/paths are selected or not.

]]--

local P = require("levelhead.data.properties")

local function clamp(obj)
	for prop in obj:iterateProperties() do
		local min, max = P:getMin(prop), P:getMax(prop)
		local val = obj:getPropertyRaw(prop)
		print(prop, val)
		if val < min then
			val = min
		elseif val > max then
			val = max
		end
		print(val, min, max)
		obj:setPropertyRaw(val)
	end
end

for obj in level.objects:iterate() do
	clamp(obj)
end
for path in level.paths:iterate() do
	clamp(path)
end