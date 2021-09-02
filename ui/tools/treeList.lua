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

]]--

function UI:initialize(dataRetriever,onClick)
	UI.super.initialize(
		self,
		settings.dim.treeViewer.entryMargin,
		settings.dim.treeViewer.textIndentSize
	)
	
	self.dataRetriever = dataRetriever
	self.onClick = onClick
	
	self.dataCache = self:toCache(dataRetriever:getRootEntries())
	
	self.buttonPadding = settings.dim.treeViewer.buttonPadding
	
	self:buildList(self.dataCache,0)
end

function UI:toCache(input)
	local out = {}
	for i,v in ipairs(input) do
		out[i] = {
			title = v.title,
			folder = v.folder,
			data = v,
			open = false,
			children = nil,
		}
	end
	return out
end

function UI:buildList(data,indentLevel)
	for _,v in ipairs(data) do
		if v.folder then
			if v.open then
				self:addButtonEntry(
					string.rep(" ",indentLevel*self.indentSize).."V "..v.title,
					function()
						v.open = false
						self:reload()
					end,
					self.buttonPadding
				):setBorder(false)
				self:buildList(v.children, indentLevel+1)
			else
				self:addButtonEntry(
					string.rep(" ",indentLevel*self.indentSize).."> "..v.title,
					function()
						v.open = true
						if not v.children then
							v.children = self:toCache(self.dataRetriever:getChildren(v.data))
						end
						self:reload()
					end,
					self.buttonPadding
				):setBorder(false)
			end
		else
			self:addButtonEntry(
				string.rep(" ",indentLevel*self.indentSize)..v.title,
				function()
					self.onClick(v.data)
				end,
				self.buttonPadding
			):setBorder(false)
		end
	end
end

function UI:reload()
	self:resetList()
	self:buildList(self.dataCache,0)
	self:minimumHeightChanged()
end

return UI
