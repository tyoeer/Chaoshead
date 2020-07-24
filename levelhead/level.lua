local Pool = require("utils.entitypool")
local DS = require("utils.datastructures")
local OBJ = require("levelhead.objects.propertiesBase")

local Level = Class()
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
	self:removeForeground(x,y)
	obj.world = self
	obj.x = x
	obj.y = y
	self.allObjects:add(obj)
	self.foreground[x][y] = obj
end

function Level:removeForeground(x,y)
	local obj = self.foreground[x][y]
	if obj then
		self:removeObject(obj)
	end
end

function Level:removeObject(obj)
	self.foreground[obj.x][obj.y] = nil
	self.allObjects:remove(obj)
	obj.world = nil
	obj.x = nil
	obj.y = nil
end

function Level:__index(key)
	if key:match("place") then
		local elem = key:match("place(.+)")
		elem = elem:gsub("([A-Z])"," %1"):trim()
		return function(self,x,y)
			local o = OBJ:new(elem)
			self:addObject(o, x,y)
			return o
		end
	end
end

-- saving/loading
-- Not Publicly Documentated because I/O shouldn't be done in user-scripts
-- in here because some of them require the world state
function Level:fileToWorldX(x)
	return x + 1
end
function Level:fileToWorldY(y)
	return self.height - y
end

function Level:worldToFileX(x)
	return x - 1
end
function Level:worldToFileY(y)
	return self.height - y
end


return Level
