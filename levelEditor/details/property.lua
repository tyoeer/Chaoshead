local P = require("levelhead.data.properties")

local UI = Class(require("ui.layout.list"))

local SEPERATOR =":  "

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
	return string.format("%s (%d)", P:getName(pl.propId), pl.propId)
end

function UI:getValues()
	local pl = self.propertyList
	if pl.min==pl.max then
		return string.format("%s (%d)",P:valueToMapping(pl.propId,pl.min),pl.min)
	else
		return string.format("%s-%s (%d-%d)",P:valueToMapping(pl.propId,pl.min),P:valueToMapping(pl.propId,pl.max),pl.min,pl.max)
	end
end

function UI:reload()
	self:reloadWithWidth(self.width)
end

function UI:reloadWithWidth(width)
	self:resetList()
	if self.propertyList then
		local name = self:getName()
		local values = self:getValues()
		local both = name..SEPERATOR..values
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
