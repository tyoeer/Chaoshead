local Level = Class()
local Pool = require("utils.entitypool")
local DS = require("utils.datastructures")
--[[

Top left corner is (1,1), to be consistent with Lua and Löve2d

]]--

function Level:initialize(w,h)
	self.width = w
	self.height = h
	self.allObjects = Pool:new()
	self.foreground = DS.grid()
end

function Level:addObject(obj,x,y)
	obj.world = self
	obj.x = x
	obj.y = y
	self.allObjects:add(obj)
	self.foreground[x][y] = obj
end

function Level:removeObject(obj)
	self.foreground[obj.x][obj.y] = nil
	self.allObjects:remove(obj)
	obj.world = nil
	obj.x = nil
	obj.y = nil
end

return Level
