local Input = require("ui.widgets.textInput")

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
		local input = Input:new(function() end, Settings.theme.details.inputStyle.inputStyle)
		input:setText(l.id)
		MainUI:displayMessage(
			"WARNING: this changes the level file directly, but doesn't directly save the change in the node data\nEnter a new id:",
			input,
			{"Confirm", function()
				MainUI:removeModal()
				local id = input:getText()
				local success, err = l:changeId(id)
				if not success then
					MainUI:displayMessage("Failed changing the level id:", err)
				end
				
				self.root:levelChanged(l)
			end}
		)
	end)
	
	if l.nodes:getTop() then
		list:addTextEntry("Nodes: ")
		for node in l.nodes:iterate() do
			list:addTextEntry(node.id,1)
		end
	else
		list:addTextEntry("Nodes: none")
	end
end

return UI
