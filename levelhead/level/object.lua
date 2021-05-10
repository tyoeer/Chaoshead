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
	return self.properties[id] or P:getDefault(id)
end

function OBJ:setProperty(id, value)
	if value==nil then
		error(string.format("Can't set property %q to nil!",id),2)
	end
	if type(id)=="string" then
		local nId = E:getPropertyID(self.id,id)
		if nId then
			id = nId
		else
			--check if this element has its properties known
			if E:hasProperties(self.id)~="$UnknownProperties" then
				error(string.format("Element %q has no property with selector %q!",self:getName(),id))
			end
			--unknown elemnt properties, just try setting all ids with this selector
			local ids = P:getAllIDs(id)
			if #ids==0 then
				error(string.format("Property %q doesn't exist!",id))
			end
			local set = false
			for _,id in ipairs(ids) do
				local isValid = false
				if type(value)=="string" then
					isValid = P:isValidMapping(id,value)
				elseif type(value)=="number" then
					isValid = P:getMin(id) <= value and value <= P:getMax(id)
				end--if it's any other type it's invalid anyway
				if isValid then
					set = true
					self:setPropertyRaw(id, P:mappingToValue(id,value))
				else
					--reset this one so getProperty knows to keep looking for an actually set one
					self:setPropertyRaw(id,nil)
				end
			end
			if not set then
				if type(value)=="string" then
					error(string.format("Mapping %q is not valid for any property with selector %q",value,id))
				else
					error(string.format("Value %d is not valid/out of bounds for any property with selector %q",value,id))
				end
			end
			--property has been set, cancel execution and allow method chaining
			return self
		end
	end
	self:setPropertyRaw(id, P:mappingToValue(id,value))
	return self
end

function OBJ:getProperty(id)
	--LH doesn't set all the properties, so this is currently a bit broken
	if type(id)=="string" then
		local nId = E:getPropertyID(self.id,id)
		if nId then
			id = nId
		else
			--check if this element has its properties known
			if E:hasProperties(self.id)~="$UnknownProperties" then
				error(string.format("Element %q has no property with selector %q!",self:getName(),id))
			end
			--unknown elemnt properties, just try setting all ids with this selector
			local ids = P:getAllIDs(id)
			if #ids==0 then
				error(string.format("Property %q doesn't exist!",id))
			end
			local default = P:valueToMapping(ids[1],P:getDefault(ids[1]))
			for _,id in ipairs(ids) do
				local value = self:getPropertyRaw(id)
				if value then
					return P:valueToMapping(id,value)
				else
					if P:valueToMapping(ids,P:getDefault(id)) ~= default then
						default = nil
					end
				end
			end
			--all properties agree on the default value
			if default then
				return default
			else
				--the element has unknown property data
				--of all the possible properties from th selector, this object has none set
				--the possible properties have different default values
				error(string.format("Property selector %q for element %q is not concise enough to return a value! (consider adding property data)",id,self:getName()))
			end
		end
	end
	return P:valueToMapping(id,self:getPropertyRaw(id) or P:getDefault(id))
end

function OBJ:__index(key)
	if key:match("set") then
		local prop = key:match("set(.+)")
		--prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,mapping)
			return self:setProperty(prop,mapping)
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
