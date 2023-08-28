local Button = require("ui.widgets.button")
local List = require("ui.layout.list")
local TextInput = require("ui.widgets.textInput")

---@class FilteredList.Item
---@field label string
---@field context unknown User-specifed thingy so they can recognise this item without string macthing
---@field filter string? string that gets checked against the filter

---@alias FilteredList.Items (string|FilteredList.Item)[]

---@class FilteredListUI : ListUI
---@field super ListUI
---@field new fun(self: self, items: FilteredList.Items, listStyle: ListStyle, textInputStyle: TextInputStyle): self
local UI = Class("FilteredListUI", List)

---@param items FilteredList.Item[]
function UI:initialize(items, listStyle, textInputStyle)
	UI.super.initialize(self, listStyle)
	
	self.input = TextInput:new(function() self:textChanged() end, textInputStyle)
	self.itemList = List:new(listStyle)
	self:setItemList(items)
	
	self:addUIEntry(self.input)
	self:addUIEntry(self.itemList)
end

function UI:grabFocus()
	self.input:grabFocus()
end

---@param items FilteredList.Items
function UI:setItemList(items)
	---@type FilteredList.Item[]
	self.items = {}
	for _,entry in ipairs(items) do
		if type(entry)=="string" then
			entry = {
				label = entry,
				context = entry,
			}
		end
		if not entry.filter then
			entry.filter = entry.label:lower()
		end
		table.insert(self.items, entry)
	end
	self:genList(self:getFilter())
end

function UI:getFilter()
	return self.input:getText():lower()
end

function UI:getItem()
	local filter = self:getFilter()
	
	local filtered = {}
	
	for _, item in ipairs(self.items) do
		if item.filter:find(filter, 1, true) then
			if item.filter==filter then
				return item.context
			end
			table.insert(filtered, item)
		end
	end
	
	if #filtered==1 then
		return filtered[1].context
	else
		return nil
	end
end

function UI:textChanged()
	self:genList(self:getFilter())
end

---@param item FilteredList.Item
function UI:itemClicked(item)
	self.input:setText(item.label)
end

function UI:genList(filter)
	self.itemList:resetList()
	for _, item in ipairs(self.items) do
		if item.filter:find(filter, 1, true) then
			self.itemList:addButtonEntry(item.label, function()
				self:itemClicked(item)
			end)
		end
	end
	-- Empty lists get a height of 0, which isn't supported when writing this
	if #self.itemList.children == 0 then
		self.itemList:addTextEntry(string.format("List filter %q matches no item",filter))
	end
	
	self.itemList:minimumHeightChanged()
end

return UI