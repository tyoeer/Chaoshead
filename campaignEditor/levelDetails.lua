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
			"Enter a new level id:",
			function(id)
				if self.root.campaign.levelsById[id] then
					MainUI:displayMessage("There already is a level with id "..id)
					return
				end
				l:setId(id)
				self.root:levelChanged(l)
			end,
			l.id
		)
	end)
	
	list:addButtonEntry("File: ".. l.file, function()
		MainUI:getString(
			"WARNING: this renames the level file directly, but doesn't directly save the change in the level data\nEnter a new file name:",
			function(fileName)
				local success, err = l:renameFile(fileName)
				if not success then
					MainUI:displayMessage("Failed renaming the level file:", err)
				end
			end,
			l.file
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
	
	list:addButtonEntry("Reload metadata", function()
		l:loadMetadata()
		self.root:levelChanged(l)
	end)
	if l.metadata then
		list:addTextEntry("Raw metadata: ")
		for key, value in pairs(l.metadata) do
			list:addTextEntry(key..": "..tostring(value), 1)
		end
	else
		list:addTextEntry("Metadata not yet loaded")
	end
end

return UI
