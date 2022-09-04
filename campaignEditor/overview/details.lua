--this class represents the details of a campaign selected in the campaign selector
local UI = Class("SelectedCampaignDetailsUI",require("ui.tools.details"))

function UI:initialize(overview,data)
	self.overview = overview
	self.subpath = data.subpath
	UI.super.initialize(self)
end

function UI:onReload(list)
	list:addTextEntry("Name: ".. self.subpath)
	
	list:addButtonEntry(
		"Open in editor",
		function()
			self.overview:openEditor(self.path)
		end
	)
	list:addButtonEntry(
		"Open in file explorer",
		function()
			local url = "file://"..love.filesystem.getSaveDirectory().."/"..self.overview.FOLDER..self.subpath
			if not love.system.openURL(url) then
				error("Couldn't open "..url)
			end
		end
	)
	
	--TODO pack?

end

return UI
