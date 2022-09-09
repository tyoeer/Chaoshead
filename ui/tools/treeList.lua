local UI = Class("TreeListUI",require("ui.layout.list"))

--[[

dataRetriever:
	getChildren(dataRetriever,parent)
		should return all the children of parent
	getRootEntries(dataRetriever)
		should return the entries at the root
		
	entry format:
		- title: title to display
		- folder: wether or not this is a folder
		- action: overwrite onClick

]]--

local theme = Settings.theme.treeViewer

function UI:initialize(dataRetriever,onClick)
	UI.super.initialize(self, theme.listStyle)
	
	self.dataRetriever = dataRetriever
	self.onClick = onClick
	
	self.dataCache = self:toCache(dataRetriever:getRootEntries())
	
	self:buildList(self.dataCache,0)
end

function UI:toCache(input)
	local out = {}
	for i,v in ipairs(input) do
		out[i] = {
			title = v.title,
			folder = v.folder,
			action = v.action,
			data = v,
			open = false,
			children = nil,
		}
	end
	return out
end

function UI:buildList(data,indentLevel)
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
						self:rebuildList()
					end
				)
				self:buildList(v.children, indentLevel+1)
			else
				self:addButtonEntry(
					indent.."> "..v.title,
					function()
						v.open = true
						if not v.children then
							v.children = self:toCache(self.dataRetriever:getChildren(v.data))
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
	self:buildList(self.dataCache,0)
	self:minimumHeightChanged()
end

function UI:reload()
	self.dataCache = self:toCache(self.dataRetriever:getRootEntries())
	self:rebuildList()
end

return UI
