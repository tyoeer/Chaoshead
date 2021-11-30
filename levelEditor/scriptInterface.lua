local UserData = require("levelhead.userData")
local Script = require("script")

local UI = Class(require("ui.tools.treeViewer"))

function UI:initialize(root)
	self.root = root
	UI.super.initialize(self)
	self.title = "Scripts"
end

function UI:getRootEntries()
	local out = {}
	for _,fileName in ipairs(love.filesystem.getDirectoryItems(Script.folder)) do
		local path = Script.folder..fileName
		table.insert(out,{
			title = fileName,
			path = path,
			folder = love.filesystem.getInfo(path).type ~= "file",
		})
	end
	return out
end

function UI:getChildren(parent)
	local out = {}
	for _,fileName in ipairs(love.filesystem.getDirectoryItems(parent.path)) do
		local path = parent.path.."/"..fileName
		table.insert(out,{
			title = fileName,
			path = path,
			folder = love.filesystem.getInfo(path).type ~= "file",
		})
	end
	return out
end

function UI:getDetailsUI(data)
	local details = require("ui.tools.details"):new(false)
	local list = details:getList()
	list:addTextEntry("Path: ".. data.path)
	
	list:addButtonEntry(
		--Just because sandboxed mode isn't supported yet,
		-- it doesn't mean the user shouldn't be notified of the dangers.
		"Execute script without sandbox (dangerous)",
		function()
			self.root:runScript(data.path,true)
		end
	)
	
	return details
end

return UI
