local Button = require("ui.widgets.button")
local List = require("ui.layout.list")
local TextInput = require("ui.widgets.textInput")

---@alias Item string
-- ---@field label string

---@class FilteredListUI : ListUI
---@field super ListUI
---@field new fun(self: self, items: Item[], listStyle: ListStyle, textInputStyle: TextInputStyle): self
local UI = Class("FilteredListUI", List)

---@param items Item[]
function UI:initialize(items, listStyle, textInputStyle)
	UI.super.initialize(self, listStyle)
	
	self.input = TextInput:new(function() self:textChanged() end, textInputStyle)
	self.itemList = List:new(listStyle)
	
	self:addUIEntry(self.input)
	self:setItemList(items) -- also adds itemList as a child down the line
end

function UI:grabFocus()
	self.input:grabFocus()
end

function UI:setItemList(items)
	self.items = items
	self:genList(self.input:getText())
end

function UI:getItem()
	local filter = self.input:getText()
	
	local filtered = {}
	
	for _, item in ipairs(self.items) do
		if item:find(filter, 1, true) then
			if item==filter then
				return item
			end
			table.insert(filtered, item)
		end
	end
	
	if #filtered==1 then
		return filtered[1]
	else
		return nil
	end
end

function UI:textChanged()
	self:genList(self.input:getText())
end

---@param item Item
function UI:itemClicked(item)
	self.input:setText(item)
end

function UI:genList(filter)
	--remove it so it doesn't propagate a lot of minimumHeightChanged events
	self:removeChild(self.itemList)
	
	self.itemList:resetList()
	for _, item in ipairs(self.items) do
		if item:find(filter, 1, true) then
			self.itemList:addButtonEntry(item, function()
				self:itemClicked(item)
			end)
		end
	end
	-- Empty lists get a height of 0, which isn't supported when writing this
	if #self.itemList.children == 0 then
		self.itemList:addTextEntry(string.format("List filter %q matches no item",filter))
	end
	
	self:addUIEntry(self.itemList)
end

return UI