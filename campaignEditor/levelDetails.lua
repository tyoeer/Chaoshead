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
	
	list:addTextEntry("Id: ".. l.id)
	
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
