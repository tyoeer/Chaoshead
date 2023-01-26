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
	self:getList():addTextEntry(field..": "..val, 1)
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
		
		list:addTextEntry("Id:")
		list:addButtonEntry(node.id, function()
			MainUI:getString(
				"Enter the new node id",
				function(id)
					if self.editor.campaign.nodesById[id] then
						MainUI:popup("There already is a node with id "..id)
						return
					end
					node:setId(id)
				end,
				node.id
			)
		end)
		
		if #node.next==0 then
			list:addTextEntry("Next: none")
		else
			list:addTextEntry("Next:")
			for _, neighbour in ipairs(node.next) do
				list:addButtonEntry(neighbour:getLabel(), function()
					self.editor:selectNode(neighbour)
				end)
			end
		end
		
		if #node.prev==0 then
			list:addTextEntry("Prev: none")
		else
			list:addTextEntry("Prev:")
			for _, neighbour in ipairs(node.prev) do
				list:addButtonEntry(neighbour:getLabel(), function()
					self.editor:selectNode(neighbour)
				end)
			end
		end
		
		list:addSeparator(false)
		
		if node.type=="level" then
			if node.level then
				list:addTextEntry("Level:")
				list:addButtonEntry(node.level:getLabel(), function()
					MainUI:popup(SetLevelUI:new(self.editor))
				end)
				if type(node.level)=="string" then
					list:addTextEntry("WARNING: This node's level wasn't found in this campaigns level list")
				elseif type(node.level)=="table" then
					list:addButtonEntry("Goto level details", function()
						self.editor.root:gotoLevel(node.level)
					end)
				end
			else
				list:addTextEntry("Level: none")
			end
			
			list:addSeparator(false)
			
			list:addButtonEntry("On-Time Delivery: "..(node.onTimeDelivery or "none"), function()
				MainUI:getString(
					"Please enter a time in seconds (decimals allowed)",
					function(str)
						local time = tonumber(str)
						if not time then
							MainUI:popup(str.." is not a valid number")
							return
						end
						self.editor:setOnTimeDelivery(time)
					end,
					node.onTimeDelivery
				)
			end)
		end
		
		list:addSeparator(true)
		
		list:addTextEntry("Raw fields:")
		self:property(node,"id")
		self:property(node,"next")
		for field,_ in pairs(node.mappings) do
			self:property(node,field)
		end
	end
end

return UI
