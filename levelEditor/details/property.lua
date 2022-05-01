local P = require("levelhead.data.properties")

local UI = Class(require("ui.layout.list"))

function UI:initialize(propertyList,listStyle)
	UI.super.initialize(self,listStyle)
	
	self:setPropertyList(propertyList)
end

function UI:setPropertyList(propertyList)
	self.propertyList = propertyList
	self:reload()
end

function UI:getName()
	local pl = self.propertyList
	local val = P:getName(pl.propId)
	if Settings.misc.editor.showRawNumbers then
		val = val.." ("..pl.propId..")"
	end
	return val
end

function UI:formatValue(rawValue)
	local propId = self.propertyList.propId
	local val = P:valueToMapping(propId, rawValue)
	if Settings.misc.editor.showRawNumbers then
		val = val.." ("..rawValue..")"
	elseif type(val)=="string" and (val:sub(1,1)=="$" or P:getMappingType(propId)=="Hybrid") then
		val = val.."/"..rawValue
	end
	return val
end

function UI:getValues()
	local pl = self.propertyList
	if pl:isRangeProperty() then
		if pl.min==pl.max then
			return self:formatValue(pl.min)
		else
			return self:formatValue(pl.min).." - "..self:formatValue(pl.max)
		end
	else
		local out = {}
		local done = {}
		for obj in pl.pool:iterate() do
			local val = obj:getProperty(pl.propId)
			if Settings.misc.editor.showRawNumbers then
				val = val.." ("..obj:getPropertyRaw(pl.propId)..")"
			end
			if not done[val] then
				done[val] = true
				table.insert(out, val)
			end
		end
		return table.concat(out, ", ")
	end
end

function UI:reload()
	self:reloadWithWidth(self.width)
end

function UI:reloadWithWidth(width)
	self:resetList()
	if self.propertyList then
		local name = self:getName()..":"
		local values = self:getValues()
		local both = name.."  "..values
		local _, lines = love.graphics.getFont():getWrap(both, width)
		if #lines > 1 then
			self:addTextEntry(name)
			self:addTextEntry(values, 1)
		else
			self:addTextEntry(both)
		end
	end
end

function UI:getMinimumHeight(width)
	--Workaround until I make a better system for getMinimumHeight in list when their items might change depending on their width
	-- Probable solution: don't use a list
	self:reloadWithWidth(width)
	local out = UI.super.getMinimumHeight(self, width)
	self:reloadWithWidth(self.width)
	return out
end

function UI:resized(...)
	UI.super.resized(self, ...)
	--reload on resize so we can change whether or not some properties and their values
	-- are put on 1 line or 2
	self:reload()
end

return UI
