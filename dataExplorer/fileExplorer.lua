local NFS = require("libs.nativefs")
local Details = require("ui.tools.details")

local UI = Class("FileExplorerUI",require("ui.tools.treeViewer"))

local ROOT_PATH = require("levelhead.misc").getDataPath()

function UI:initialize(overview)
	self.overview = overview
	UI.super.initialize(self)
	self.title = "File Explorer"
end

function UI:getItems(path)
	local out = {}
	for _,item in ipairs(NFS.getDirectoryItemsInfo(ROOT_PATH..path)) do
		local isDir = item.type~="file"
		table.insert(out,{
			title = item.name,
			folder = isDir,
			path = path .. item.name .. (isDir and "/" or ""),
		})
	end
	return out
end

function UI:getRootEntries()
	return self:getItems("")
end

function UI:getChildren(node)
	return self:getItems(node.path)
end

function UI:getDetailsUI(node)
	local info = NFS.getInfo(ROOT_PATH.. node.path)
	local details = Details:new(false)
	local list = details:getList()
	
	list:addTextEntry("Subpath: ".. node.path)
	list:addTextEntry("Size: "..(info.size or "undetermined"))
	list:addTextEntry("Last modified: "..(info.modtime and os.date("%Y/%m/%d %H:%M:%S",info.modtime) or "undetermined"))
	
	local extension = node.path:match("%.([^/]+)$")
	list:addTextEntry("Extension: "..(extension or "undetermined"))
	
	list:addButtonEntry("Open in text viewer",function()
		self.overview:openTextViewer(node.path)
	end)
	if not extension then
		list:addButtonEntry("Open in data file viewer",function()
			self.overview:openDataFileViewer(node.path)
		end)
	end
	if not extension or extension=="json" then
		list:addButtonEntry("Open in JSON viewer",function()
			self.overview:openJSONViewer(node.path)
		end)
	end
	if not extension or extension=="lhs" then
		list:addButtonEntry("Open in LHS hex inspector",function()
			self.overview:openLHSHexInspector(node.path)
		end)
	end
	
	return details
end

return UI
