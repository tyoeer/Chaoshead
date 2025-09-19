local UserData = require("levelhead.userData")
local Script = require("script")

---@class ScriptInterfaceUI: DetailsUI
---@field super DetailsUI
---@field new fun(self, data: unknown, root: LevelRootUI): self
local DetUI = Class("ScriptInterfaceUI",require("ui.tools.details"))

---@param root LevelRootUI
function DetUI:initialize(data,root)
	self.data = data
	self.root = root
	DetUI.super.initialize(self, true)
end

function DetUI:onReload(list)
	list:resetList()
	local path = self.data.path
	local contents = love.filesystem.read(path, 2000);
	local description = string.match(contents, "^%-%-%[%[\n*([^%]]+)\n*%]?%]?--")
	if description then
		list:addTextEntry(description)
	end
	
	list:addTextEntry("Path: ".. path)
	list:addButtonEntry(
		--Just because sandboxed mode isn't supported yet,
		-- it doesn't mean the user shouldn't be notified of the dangers.
		"Execute script without sandbox (dangerous)",
		function()
			self.root:runScript(path,true)
		end
	)
	if Storage.quickRunScriptPath == path then
		list:addButtonEntry(
			"Unbind quick run hotkey",
			function()
				Storage.quickRunScriptPath = nil
				Storage:save()
				self:reload()
			end
		)
	else
		list:addButtonEntry(
			"Bind quick run hotkey to this script",
			function()
				Storage.quickRunScriptPath = path
				Storage:save()
				self:reload()
			end
		)
	end
end


---@class ScriptExplorerUI: TreeViewerUI
---@field super TreeViewerUI
---@field new fun(self, root: LevelRootUI): self
local UI = Class("ScriptExplorerUI",require("ui.tools.treeViewer"))

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
	return DetUI:new(data,self.root)
end

return UI
