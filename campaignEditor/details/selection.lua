

UI = Class("CampaignSelectionDetailsUI",require("ui.tools.details"))

function UI:initialize(editor)
	self.editor = editor
	UI.super.initialize(self,true)
	self.title = "Selection"
end

function UI:property(node, field)
	self:getList():addTextEntry(field..": "..tostring(node[field]))
end

function UI:onReload(list)
	list:resetList()
	local s = self.editor.selection
	local n = self.editor.selectionSize
	--counts + layer filters
	do
		list:addTextEntry("Nodes: "..n)
		list:addButtonEntry("Deselect all",function()
			self.editor:deselectAll()
		end)

	end
	--add a divider
	list:addTextEntry(" ",0)
	
	-- info & co
	list:addButtonEntry("Delete (TODO)",function()
		self.editor:deleteSelection()
	end)
	
	--add a divider
	list:addTextEntry(" ",0)

	--single node properties
	if n==1 then
		local node = s:getTop()
		for field,_ in pairs(node.mappings) do
			self:property(node,field)
		end
	end
end

return UI
