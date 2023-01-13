local SetLevelUI = require("campaignEditor.details.setLevel")

UI = Class("CampaignSelectionDetailsUI",require("ui.tools.details"))

function UI:initialize(editor)
	self.editor = editor
	UI.super.initialize(self,true)
	self.title = "Selection"
end

function UI:property(node, field)
	local val = node[field]
	if type(val)=="table" then
		if val.id then
			val = val.id
		else
			local out = ""
			local first = true
			for _,v in ipairs(val) do
				if not first then
					out = out .. ", "
				end
				if type(v)=="table" and v.id then
					out = out.. v.id
				else
					out = out..tostring(v)
				end
				first = false
			end
			val = out=="" and "$Empty" or out
		end
	else
		val = tostring(val)
	end
	self:getList():addTextEntry(field..": "..val)
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
	list:addSeparator(true)
	
	-- TODO deletion
	-- -- info & co
	-- list:addButtonEntry("Delete",function()
	-- 	self.editor:deleteSelection()
	-- end)

	--single node properties
	if n==1 then
		local node = s:getTop()
		
		if node.type=="level" then
			if type(node.level)=="string" then
				list:addTextEntry("WARNING: This node's level wasn't found in this campaigns level list")
			end
			
			list:addButtonEntry("Set level", function()
				MainUI:displayMessage(SetLevelUI:new(self.editor))
			end)
			
			if type(node.level)=="table" then
				list:addButtonEntry("Goto level details", function()
					self.editor.root:gotoLevel(node.level)
				end)
			end
		end
		
		self:property(node,"id")
		self:property(node,"next")
		for field,_ in pairs(node.mappings) do
			self:property(node,field)
		end
	end
end

return UI
