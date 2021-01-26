local E = require("levelhead.data.elements")
local P = require("levelhead.data.properties")

local OBJ = Class("Object")

function OBJ:initialize(id)
	self.id = E:getID(id)
	self.properties = {}
	--self.x = nil
	--self.y = nil
	--self.world = nil
	--self.layer = nil
	--self.contents
end

-- MISC


function OBJ:getName()
	return E:getName(self.id)
end


-- CONTAINED OBJECTS


function OBJ:setContents(element)
	self.contents = E:getID(element)
end

function OBJ:getContents()
	return self.contents and E:getName(self.contents)
end


-- DRAWING


function OBJ:drawAsForeground()
	local drawX = (self.x-1)*TILE_SIZE
	local drawY = (self.y-1)*TILE_SIZE
	
	love.graphics.setColor(0,1,0,0.4)
	love.graphics.rectangle("fill",drawX,drawY,TILE_SIZE,TILE_SIZE)
	love.graphics.setColor(0,0,0,1)
	
	love.graphics.print(self.id,drawX+2,drawY+2)
	
	love.graphics.setColor(0,1,0,1)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line",drawX+0.5,drawY+0.5,TILE_SIZE-1,TILE_SIZE-1)
end

function OBJ:drawAsBackground()
	local x = (self.x-1)*TILE_SIZE
	local y = (self.y-1)*TILE_SIZE
	
	love.graphics.setColor(1,0,0,0.4)
	love.graphics.polygon("fill",
		x+ 20.5, y+ 0.5,
		x+ 50.5, y+ 0.5,
		x+ 70.5, y+ 20.5,
		x+ 70.5, y+ 50.5,
		
		x+ 50.5, y+ 70.5,
		x+ 20.5, y+ 70.5,
		x+ 0.5,  y+ 50.5,
		x+ 0.5,  y+ 20.5
	)
	love.graphics.setColor(0,0,0,1)
	
	love.graphics.print(self.id, x+20,y+51)
	
	love.graphics.setColor(1,0,0,1)
	love.graphics.setLineWidth(1)
	love.graphics.polygon("line",
		x+ 20.5, y+ 0.5,
		x+ 50.5, y+ 0.5,
		x+ 70.5, y+ 20.5,
		x+ 70.5, y+ 50.5,
		
		x+ 50.5, y+ 70.5,
		x+ 20.5, y+ 70.5,
		x+ 0.5,  y+ 50.5,
		x+ 0.5,  y+ 20.5
	)
end


-- PROPERTIES


function OBJ:setPropertyRaw(id, value)
	self.properties[id] = value
end

function OBJ:getPropertyRaw(id)
	return self.properties[id]
end

function OBJ:setProperty(id, value)
	if value==nil then
		error(string.format("Can't set property %q to nil!",id),2)
	end
	id = P:getID(id)
	self:setPropertyRaw(id,P:mappingToValue(id,value))
end

function OBJ:getProperty(id)
	--LH doesn't set all the properties, so this is currently a bit broken
	id = P:getID(id)
	return P:valueToMapping(id,self:getPropertyRaw(id))
end

function OBJ:__index(key)
	if key:match("set") then
		local prop = key:match("set(.+)")
		--prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,mapping)
			local exists = false
			local set = false
			for _,id in ipairs(P:getAllIDs(prop)) do
				exists = true
				if P:isValidMapping(id,mapping) then
					set = true
					self:setProperty(id, mapping)
				end
			end
			if not set then
				if exists then
					error("Mapping "..mapping.." is invalid for property "..prop)
				else
					error("Property "..prop.." doesn't exist")
				end
			end
		end
	elseif key:match("get") then
		local prop = key:match("get(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self)
			return self:getProperty(prop)
		end
	end
end

return OBJ
