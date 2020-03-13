local World = Class()
local Pool = require("utils.entitypool")
local DS = require("utils.datastructures")
--[[

Top left corner is (1,1), to be consistent with Lua and Löve2d

]]--

function World:initialize(w,h)
	self.width = w
	self.height = h
	self.allObjects = Pool:new()
	self.foreground = DS.grid()
end

function World:addObject(obj)
	obj.world = self
	self.allObjects:add(obj)
	self.foreground[obj.x][obj.y] = obj
end

function World:removeObject(obj)
	obj.world = nil
	self.allObjects:remove(obj)
	self.foreground[obj.x][obj.y] = nil
end

return World
