local DataFile = require("levelhead.dataFile")

local ROOT_PATH = require("levelhead.misc").getDataPath()

local UI = Class("DataFileViewerUI",require("dataExplorer.viewers.table"))

function UI:initialize(path,overview)
	self.dataFile = DataFile:new(ROOT_PATH..path)
	
	local data = {
		json = self.dataFile.raw,
		mystery = self.dataFile.mystery,
		hash = self.dataFile.hash
	}
	
	UI.super.initialize(self,data,overview)
	self.title = "Data File Viewer"
end

return UI
