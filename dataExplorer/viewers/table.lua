local Details = require("ui.tools.details")

local UI = Class("TableViewerUI",require("ui.tools.treeViewer"))

function UI:initialize(data,overview)
	self.data = data
	UI.super.initialize(self)
	self.title = "Table Viewer"
end

function UI:getRootEntries()
	local out = {}
	for k,v in pairs(self.data) do
		table.insert(out,{
			title = k,
			folder = type(v)=="table",
			raw = v,
		})
	end
	return out
end

function UI:getChildren(node)
	local out = {}
	for k,v in pairs(node.raw) do
		table.insert(out,{
			title = k,
			folder = type(v)=="table",
			raw = v,
		})
	end
	return out
end

function UI:getDetailsUI(data)
	local details = Details:new(false)
	local list = details:getList()
	
	local t = type(data.raw)
	if t=="string" then
		if t:len() > settings.misc.dataExplorer.maxDisplayStringLength then
			list:addTextEntry("String: too long to display!")
		else
			list:addTextEntry("String:")
			list:addTextEntry(data.raw)
		end
	else
		list:addTextEntry(type(data.raw)..":")
		list:addTextEntry(tostring(data.raw))
	end
	
	return details
end

return UI
