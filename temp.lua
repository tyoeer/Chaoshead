--[[

	This file is for temporary stuff to do things when their proper system hasn't been made yet.
	If this file gets longer than 50 lines, ring the alarm bell.

]]--
function script(name)
	local text = love.filesystem.read("scripts/"..name..".lua")
	local f,errorMessage = loadstring(text)
	if not f then error(errorMessage) end
	return f(level)
end
