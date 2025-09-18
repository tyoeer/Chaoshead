local JSON = require("libs.json")
local NFS = require("libs.nativefs")

local ROOT_PATH = require("levelhead.misc").getDataPath()

local UI = Class("JsonViewerUI",require("dataExplorer.viewers.table"))

function UI:initialize(path,overview)
	UI.super.initialize(self,JSON.decode(NFS.read(ROOT_PATH..path)),overview)
	self.title = "JSON File Viewer"
end

return UI
