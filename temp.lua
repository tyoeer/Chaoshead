--[[

	This file is for temporary stuff to do things when their proper system hasn't been made yet.
	If this file gets longer than 50 lines, ring the alarm bell.

]]--
function loadScript(name)
	local text = love.filesystem.read("scripts/"..name..".lua")
	local f = loadstring(text)
	return f(world)
end
