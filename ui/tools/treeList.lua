---@class TreeListEntry
---@field title string titel to display
---@field folder boolean whetehr or not this is a folder
---@field action fun(this: TreeListEntry)? overwrites onClick if present

---@class TreeList.DataRetriever
---@field persistant string name to remember under which entries have been opened
---@field getRootEntries fun(self): TreeListEntry[] should return the entries at the root
---@field getChildren fun(self, parent: TreeListEntry): TreeListEntry[] should return all the children of parent

---@alias Opened table<string,Opened>
---@alias TreeList.OnClick fun(entry: TreeListEntry)

---@class TreeListUI : ListUI
---@field super ListUI
---@field opened Opened?
---@field new fun(self, dataRetriever: TreeList.DataRetriever, onClick: TreeList.OnClick): self
local UI = Class("TreeListUI",require("ui.layout.list"))


local treeStorage = Persistant:get("tree")
local theme = Settings.theme.treeViewer

---@param dataRetriever TreeList.DataRetriever
---@param onClick TreeList.OnClick
function UI:initialize(dataRetriever,onClick)
	UI.super.initialize(self, theme.listStyle)
	
	self.dataRetriever = dataRetriever
	if dataRetriever.persistant then
		if not treeStorage[dataRetriever.persistant] then
			treeStorage[dataRetriever.persistant] = {}
		end
		self.opened = treeStorage[dataRetriever.persistant]
	end
	self.onClick = onClick
	
	self.dataCache = self:toCache(dataRetriever:getRootEntries(), self.opened)
	
	self:buildList(self.dataCache,0, self.opened)
end

---@param input TreeListEntry[]
---@param opened Opened?
function UI:toCache(input, opened)
	local out = {}
	for i,v in ipairs(input) do
		out[i] = {
			title = tostring(v.title),
			folder = v.folder,
			action = v.action,
			data = v,
			open = false,
			children = nil,
		}
		if opened and opened[v.title] then
			out[i].open = true
			out[i].children = self:toCache(self.dataRetriever:getChildren(v), opened and opened[v.title])
		end
	end
	return out
end

---@param opened Opened?
function UI:buildList(data,indentLevel, opened)
	for _,v in ipairs(data) do
		local indent = string.rep(" ",indentLevel*self.style.indentCharacters)
		if v.action then
			self:addButtonEntry(
				indent..v.title,
				function()
					v:action(v.data)
				end,
				self.style.actionButtonStyle
			)
		elseif v.folder then
			if v.open then
				self:addButtonEntry(
					indent.."V "..v.title,
					function()
						v.open = false
						if opened then
							opened[v.title] = nil
						end
						self:rebuildList()
					end
				)
				self:buildList(v.children, indentLevel+1, opened and opened[v.title])
			else
				self:addButtonEntry(
					indent.."> "..v.title,
					function()
						v.open = true
						if opened and not opened[v.title] then
							opened[v.title] = {}
						end
						if not v.children then
							v.children = self:toCache(self.dataRetriever:getChildren(v.data), opened and opened[v.title])
						end
						self:rebuildList()
					end
				)
			end
		else
			self:addButtonEntry(
				indent..v.title,
				function()
					self.onClick(v.data)
				end
			)
		end
	end
end

function UI:rebuildList()
	self:resetList()
	self:buildList(self.dataCache,0, self.opened)
	if self.opened then
		treeStorage:save()
	end
	self:minimumHeightChanged()
end

function UI:reload()
	self.dataCache = self:toCache(self.dataRetriever:getRootEntries(), self.opened)
	self:rebuildList()
end

return UI
