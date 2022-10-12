local Details = require("campaignEditor.overview.details")
local CampaignMisc = require("campaignEditor.misc")

local UI = Class("CampaignSelectorUI",require("ui.tools.treeViewer"))

function UI:initialize(overview)
	self.overview = overview
	UI.super.initialize(self)
	self.title = "Campaign Selection"
end

function UI:getRootEntries()
	local out = {}
	
	table.insert(out,{
		title = "Unpack campaign_hardfile",
		action = function()
			CampaignMisc.unpack(function()
				self.list:reload()
			end)
		end,
	})
	
	if Storage.lastCampaignOpened then
		table.insert(out,{
			title = Storage.lastCampaignOpened.subpath,
			action = function()
				self.overview:openEditor(Storage.lastCampaignOpened.subpath)
			end
		})
	end
	
	-- make sure folder exists
	local info = love.filesystem.getInfo(CampaignMisc.folder)
	if not info then
		love.filesystem.createDirectory(CampaignMisc.folder)
	end
	for _,dirname in ipairs(love.filesystem.getDirectoryItems(CampaignMisc.folder)) do
		table.insert(out,{
			title = dirname,
			subpath = dirname
		})
	end
	return out
end

function UI:getDetailsUI(data)
	return Details:new(self.overview, data)
end

return UI
