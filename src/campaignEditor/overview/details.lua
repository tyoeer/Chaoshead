local CampaignMisc = require("campaignEditor.misc")
local JSON = require("libs.json")
local LhData = require("levelhead.dataFile")
local LhMisc = require("levelhead.misc")
local Campaign = require("levelhead.campaign.campaign")

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
			self.overview:openEditor(self.subpath)
		end
	)
	list:addButtonEntry(
		"Open in file explorer",
		function()
			local url = "file://"..love.filesystem.getSaveDirectory().."/"..CampaignMisc.folder..self.subpath
			if not love.system.openURL(url) then
				error("Couldn't open "..url)
			end
		end
	)
	
	list:addSeparator(false)
	
	list:addButtonEntry("Overwrite data with data from the in-game editor", function()
		local data = LhData:new(LhMisc:getDataPath().."CampaignMaster/LHCampaignMaster")
		
		local dataPath = CampaignMisc.folder .. self.subpath .. "/" .. Campaign.SUBPATHS.data
		
		for category, data in pairs(data.raw) do
			print(dataPath..category..".json")
			local success, err = love.filesystem.write(dataPath..category..".json", JSON.encode(data))
			if not success then
				MainUI:popup("Failed overwriting a data file (other may have been edited though):", err)
				return
			end
		end
		
		MainUI:popup("Successfully overwrote campaign data")
	end)
	
	list:addSeparator(false)
	
	list:addButtonEntry(
		"Pack",
		function()
			CampaignMisc.pack(CampaignMisc.folder..self.subpath)
		end
	)

end

return UI
