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
OBJ.setContainedObject = OBJ.setContents
OBJ.setThingInsideThisThing = OBJ.setContents

function OBJ:getContents()
	return self.contents and E:getName(self.contents)
end
OBJ.getContainedObject = OBJ.getContents
OBJ.getThingInsideThisThing = OBJ.getContents

-- DRAWING

OBJ.backgroundShape = {
	20.5, 0.5,
	50.5, 0.5,
	70.5, 20.5,
	70.5, 50.5,
	
	50.5, 70.5,
	20.5, 70.5,
	0.5,  50.5,
	0.5,  20.5
}
function OBJ:getDrawCoords()
	return self.x*TILE_SIZE, self.y*TILE_SIZE
end

function OBJ:drawShape()
	local x, y = self:getDrawCoords()
	if self.layer=="foreground" then
		love.graphics.setColor(settings.col.editor.objects.foreground.shape)
		love.graphics.rectangle("fill",x,y,TILE_SIZE,TILE_SIZE)
	else --background
		love.graphics.setColor(settings.col.editor.objects.background.shape)
		love.graphics.translate(x,y)
		love.graphics.polygon("fill",self.backgroundShape)
		love.graphics.translate(-x,-y)
	end
end

function OBJ:drawText()
	local x, y = self:getDrawCoords()
	if self.layer=="foreground" then
		love.graphics.setColor(settings.col.editor.objects.foreground.text)
		love.graphics.print(self.id,x+2,y+2)
	else --background
		love.graphics.setColor(settings.col.editor.objects.background.text)
		love.graphics.print(self.id, x+20,y+51)
	end
end

function OBJ:drawOutline()
	local x, y = self:getDrawCoords()
	if self.layer=="foreground" then
		love.graphics.setColor(settings.col.editor.objects.foreground.outline)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle("line",x+0.5,y+0.5,TILE_SIZE-1,TILE_SIZE-1)
	else --background
		love.graphics.setColor(settings.col.editor.objects.background.outline)
		love.graphics.setLineWidth(1)
		love.graphics.translate(x,y)
		love.graphics.polygon("line",self.backgroundShape)
		love.graphics.translate(-x,-y)
	end
end


-- PROPERTIES

function OBJ:hasProperties()
	local e = E:hasProperties(self.id)
	if e=="$UnknownProperties" then
		-- next returns nil if self.properties is empty
		return next(self.properties) and true or false
	else
		return e
	end
end

function OBJ:iterateProperties()
	if E:hasProperties(self.id)=="$UnknownProperties" then
		return pairs(self.properties)
	else
		return E:iterateProperties(self.id)
	end
end


function OBJ:setPropertyRaw(id, value)
	self.properties[id] = value
	return self
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
	return self
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
					return self
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
