local UI = Class("CampaignLevelDetailsUI",require("ui.tools.details"))

function UI:initialize(root, level)
	self.root = root
	self.level = level
	UI.super.initialize(self)
end

function UI:onReload(list, level)
	if level then
		self.level = level
	end
	local l = self.level
	
	list:resetList()
	
	list:addButtonEntry("Id: ".. l.id, function()
		MainUI:getString(
			"WARNING: this changes the level file directly, but doesn't directly save the change in the node data\nEnter a new id:",
			function(id)
				if self.root.campaign.levelsById[id] then
					MainUI:displayMessage("There already is a level with id "..id)
					return
				end
				
				local success, err = l:changeId(id)
				if not success then
					MainUI:displayMessage("Failed changing the level id:", err)
				end
				
				self.root:levelChanged(l)
			end,
			l.id
		)
	end)
	
	if l.nodes:getTop() then
		list:addTextEntry("Nodes: ")
		for node in l.nodes:iterate() do
			list:addButtonEntry(node.id, function()
				self.root:gotoNode(node)
			end)
		end
	else
		list:addTextEntry("Nodes: none")
	end
end

return UI
