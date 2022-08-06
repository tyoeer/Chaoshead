local DS = require("libs.tyoeerUtils.datastructures")

--the bitplane itself
local B = Class("Bitplane")

function B:initialize(w,h,default)
	self.width = w
	self.height = h
	if default==nil then
		self.default = false
	else
		self.default = default
	end
	self.grid = DS.grid()
end

function B:get(x,y)
	if self.grid[x][y]==nil then
		return self.default
	else
		return self.grid[x][y]
	end
end

function B:rectContains(x,y, w,h, value)
	for i=x, x+w-1, 1 do
		for j=y, y+h-1, 1 do
			if self:get(i,j)==value then
				return true
			end
		end
	end
	return false
end

function B:set(x,y,value)
	if value==nil then
		value = true
	end
	self.grid[x][y] = value
end

function B:setRect(x,y, w,h, value)
	for i=x, x+w-1, 1 do
		for j=y, y+h-1, 1 do
			self.grid[i][j] = value
		end
	end
end

function B:iterateFunction(func)
	for y=1,self.height,1 do
		for x=1,self.width,1 do
			func(x,y,self:get(x,y))
		end
	end
end
B.forEach = B.iterateFunction

--static methods
local Bitplane = {}

--construction

Bitplane.new = function(a, ...)
	if a==Bitplane then
		error("This should not called as OOP! (use . instead of :)",2)
	end
	return B:new(a, ...)
end

function Bitplane.newFromStrings(falseMask,trueMask,...)
	local input = {...}
	if type(input[1])=="table" then
		input = input[1]
	end
	local h = #input
	local w = input[1]:len()
	local out = B:new(w,h)
	for y=1,h,1 do
		local line = input[y]
		for x=1,w,1 do
			local c = input[y]:sub(x,x)
			local val
			if falseMask:match(c:depatternize()) then
				val = false
			elseif trueMask:match(c:depatternize()) then
				val = true
			else
				error("Input char doesn't match masks: "..c.." -f "..falseMask.." -t "..trueMask)
			end
			out:set(x,y,val)
		end
	end
	return out
end

--new ones adapted from old ones

function Bitplane.invert(src)
	local out = B:new(src.width, src.height)
	src:iterateFunction(function(x,y,val)
		out:set(x,y, not val)
	end)
	return out
end
Bitplane.bnot = Bitplane.invert

function Bitplane.bor(a,b)
	if a.width ~= b.width or a.height ~= b.height then
		error("Bitplane dimensions mismatch!")
	end
	local out = B:new(a.width, a.height)
	a:iterateFunction(function(x,y,val)
		out:set(x,y, val or b:get(x,y) )
	end)
	return out
end

function Bitplane.band(a,b)
	if a.width ~= b.width or a.height ~= b.height then
		error("Bitplane dimensions mismatch!")
	end
	local out = B:new(a.width, a.height)
	a:iterateFunction(function(x,y,val)
		out:set(x,y, val and b:get(x,y) )
	end)
	return out
end

function Bitplane.xor(a,b)
	if a.width ~= b.width or a.height ~= b.height then
		error("Bitplane dimensions mismatch!")
	end
	local out = B:new(a.width, a.height)
	a:iterateFunction(function(x,y,val)
		out:set(x,y, val ~= b:get(x,y) )
	end)
	return out
end
Bitplane.bxor = Bitplane.xor

return Bitplane
