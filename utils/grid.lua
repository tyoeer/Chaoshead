---@class Grid : Class
local Grid = Class("Grid")

local dataMetatable = {
	__index=function(table,key)
		--add an empty table for the column
		rawset(table, key, {})
		return rawget(table,key)
	end
}

function Grid:initialize()
	self.data = setmetatable({},dataMetatable)
end

function Grid:set(x,y,value)
	self.data[x][y]=value
end

function Grid:get(x,y)
	return self.data[x][y]
end

function Grid:__call(x,y,value)
	if value==nil then
		return self:get(x,y)
	else
		self:set(x,y,value)
	end
end

function Grid:__index(k)
	return self.data[k]
end

return Grid