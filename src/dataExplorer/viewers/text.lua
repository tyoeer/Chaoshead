local NFS = require("libs.nativefs")
local Utf8 = require("utf8")

local UI = Class("TextViewerUI",require("ui.tools.details"))

local ROOT_PATH = require("levelhead.misc").getDataPath()

function UI:initialize(path,overview)
	self.overview = overview
	self.path = path
	UI.super.initialize(self,true)
	self.title = path
end

function UI:onReload(list)
	local text = NFS.read(ROOT_PATH..self.path)
	local isValid = Utf8.len(text)
	if not isValid then
		list:addTextEntry("File contains invalid UTF-8!")
	end
	list:addButtonEntry("Close viewer", function()
		self.overview:closeViewer(self)
	end)
	if isValid then
		list:addTextEntry(text)
	end
end

return UI
