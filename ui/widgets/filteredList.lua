local Button = require("ui.widgets.button")
local List = require("ui.layout.list")
local TextInput = require("ui.widgets.textInput")

---@class FLItem
---@field label string
---@field context unknown User-specifed thingy so they can recognise this item without string macthing
---@field filter string string that gets checked against the filter

---@alias FLItems (string|FLItem)[]

---@class FilteredListUI : ListUI
---@field super ListUI
---@field new fun(self: self, items: FLItems, listStyle: ListStyle, textInputStyle: TextInputStyle): self
local UI = Class("FilteredListUI", List)

---@param items FLItem[]
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

---@param items FLItems
function UI:setItemList(items)
	---@type FLItem[]
	self.items = {}
	for _,entry in ipairs(items) do
		if type(entry)=="string" then
			table.insert(self.items, {
				label = entry,
				context = entry,
				filter = entry:lower(),
			})
		else
			table.insert(self.items, entry)
		end
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

---@param item FLItem
function UI:itemClicked(item)
	self.input:setText(item.label)
end

function UI:genList(filter)
	--remove it so it doesn't propagate a lot of minimumHeightChanged events
	self:removeChild(self.itemList)
	
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
	
	self:addUIEntry(self.itemList)
end

return UI