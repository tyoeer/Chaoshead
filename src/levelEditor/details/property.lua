local P = require("levelhead.data.properties")

---@class PropertyDetailsUI : ListUI
---@field super ListUI
---@field new fun(self, propertyList: PropertyList, listStyle: ListStyle): self
local UI = Class("PropertyDetailsUI",require("ui.layout.list"))

function UI:initialize(propertyList,listStyle)
	-- self.name = ""
	-- self.values = ""
	
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
	self:resetList()
	
	self.name = self:getName()..":"
	self.values = self:getValues()
	local both = self.name.."  "..self.values
	local _, lines = love.graphics.getFont():getWrap(both, self.width)
	if #lines > 1 then
		self:addTextEntry(self.name)
		self:addTextEntry(self.values, 1)
	else
		self:addTextEntry(both)
	end
	self:minimumHeightChanged()
end

function UI:getMinimumHeight(width)
	local font = love.graphics.getFont()
	local _, lines = font:getWrap(self.name.."  "..self.values, width)
	if #lines > 1 then
		local _, nLines = font:getWrap(self.name, width)
		local _, vLines = font:getWrap(self.values, width-self.style.textIndentSize)
		local lines = #nLines + #vLines
		return lines * font:getHeight() * font:getLineHeight() + self.style.entryMargin
	else
		return font:getHeight() * font:getLineHeight()
	end
end

function UI:resized(w,h)
	local oldWidth = self.width
	UI.super.resized(self, w,h)
	if w~=oldWidth then
		--reload so we can change whether or not some properties and their values are put on 1 or more lines
		self:reload()
	end
end

return UI
