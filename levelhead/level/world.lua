local Set = require("utils.orderedSet")
local Grid = require("utils.grid")
local OBJ = require("levelhead.level.object")
local Path = require("levelhead.level.path")
local E = require("levelhead.data.elements")

local World = Class()
--[[

Top left corner is (1,1), to be consistent with Lua and Löve2d

]]--

function World:initialize()
	self.left = 1
	self.right = 2
	self.top = 1
	self.bottom = 2
	
	self.objects = Set:new()
	self.foreground = Grid:new()
	self.background = Grid:new()
	
	self.paths = Set:new()
	self.pathNodes = Grid:new()
end

--misc

function World:getWidth()
	return self.right - self.left + 1
end

function World:getHeight()
	return self.bottom - self.top + 1
end

--foreground & background

function World:addObject(obj,x,y)
	if obj.layer=="foreground" then
		self:addForegroundObject(obj,x,y)
	elseif obj.layer=="background" then
		self:addBackgroundObject(obj,x,y)
	else
		local layer = E:getLayer(obj.id)
		if layer=="Background" then
			self:addBackgroundObject(obj,x,y)
		else
			self:addForegroundObject(obj,x,y)
		end
	end
end

function World:moveObject(obj,x,y)
	if obj.layer=="foreground" then
		self:moveForegroundObject(obj,x,y)
	else -- background
		self:moveBackgroundObject(obj,x,y)
	end
end

function World:removeObject(obj)
	self[obj.layer][obj.x][obj.y] = nil
	self.objects:remove(obj)
	obj.world = nil
	obj.layer = nil
	obj.x = nil
	obj.y = nil
end

--foreground

function World:addForegroundObject(obj,x,y)
	self:removeForegroundAt(x,y)
	obj.world = self
	obj.layer = "foreground"
	obj.x = x
	obj.y = y
	self.objects:add(obj)
	self.foreground[x][y] = obj
end

function World:moveForegroundObject(obj,x,y)
	self.foreground[obj.x][obj.y] = nil
	self:removeForegroundAt(x,y)
	obj.x = x
	obj.y = y
	self.foreground[x][y] = obj
end

function World:removeForegroundAt(x,y)
	local obj = self.foreground[x][y]
	if obj then
		self:removeObject(obj)
	end
end

function World:__index(key)
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

--background

function World:addBackgroundObject(obj,x,y)
	self:removeBackgroundAt(x,y)
	obj.world = self
	obj.layer = "background"
	obj.x = x
	obj.y = y
	self.objects:add(obj)
	self.background[x][y] = obj
end

function World:moveBackgroundObject(obj,x,y)
	self.background[obj.x][obj.y] = nil
	self:removeBackgroundAt(x,y)
	obj.x = x
	obj.y = y
	self.background[x][y] = obj
end

function World:removeBackgroundAt(x,y)
	local obj = self.background[x][y]
	if obj then
		self:removeObject(obj)
	end
end

-- paths

function World:newPath()
	local p = Path:new()
	self:addPath(p)
	return p
end

function World:addPath(p)
	self.paths:add(p)
	p.world = self
	for node in p:iterateNodes() do
		self:addPathNodeRaw(node)
	end
end

function World:removePath(p)
	p.world = nil
	self.paths:remove(p)
	--remove all nodes
	local n = p.head
	while n do
		self:removePathNodeRaw(n)
		n = n.next
	end
end

function World:movePathNode(node,x,y)
	self.pathNodes[node.x][node.y] = nil
	self:removePathNodeAt(x,y)
	node.x = x
	node.y = y
	self.pathNodes[x][y] = node
end

function World:removePathNodeAt(x,y)
	local pn = self.pathNodes[x][y]
	if pn then
		self:removePathNodeRaw(pn)
		pn.path:removeNodeRaw(pn)
	end
end

--doesn't properly connect, private use only
function World:addPathNodeRaw(n)
	--remove previous node at this position
	self:removePathNodeAt(n.x,n.y)
	self.pathNodes[n.x][n.y] = n
end

--doesn't properly disconnect everything, internal use only
function World:removePathNodeRaw(pn)
	self.pathNodes[pn.x][pn.y] = nil
end

-- saving/loading
-- Not Publicly Documentated because I/O shouldn't be done in user-scripts
-- in here because some of them require the world state
function World:fileToWorldX(x)
	return x + self.left
end
function World:fileToWorldY(y)
	return self.bottom - y
end

function World:worldToFileX(x)
	return x - self.left
end
function World:worldToFileY(y)
	return self.bottom - y
end


return World
