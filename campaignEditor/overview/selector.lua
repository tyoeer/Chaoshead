local Details = require("campaignEditor.overview.details")
local List = require("ui.layout.list")
local ParsedInput = require("ui.layout.parsedInput")
local Packing = require("levelhead.campaign.packing")

local UI = Class("CampaignSelectorUI",require("ui.tools.treeViewer"))

function UI:initialize(overview)
	self.overview = overview
	self.folder = overview.FOLDER --can't require it because that would lead to recursive require()s
	UI.super.initialize(self)
	self.title = "Campaign Selection"
end

function UI:getRootEntries()
	local out = {}
	
	table.insert(out,{
		title = "Unpack campaign_hardfile",
		action = function()
			local info = love.filesystem.getInfo("campaign_hardfile")
			if info then
				local list = List:new(Settings.theme.modal.listStyle)
				list:addTextEntry("Enter the name/subpath to unpack the campaign to:")
				local input = ParsedInput:new(function(str)
					if str:match("[<>:\"/\\|%?%*]") then
						return nil, "The following characters aren't allowed in Windows directory names: <>:\"/\\|?*"
					else
						return str
					end
				end,Settings.theme.details.inputStyle)
				list:addUIEntry(input)
				list:addButtonEntry("Unpack",function()
					MainUI:removeModal() --manual dismiss of the current modal
					local subpath = input:getParsed()
					if not subpath or subpath=="" then
						MainUI:displayMessage("The path you entered was invalid!")
						return
					end
					Packing.unpack(self.folder..subpath)
					self.list:reload()
				end)
				local cancel = function()
					MainUI:removeModal()
				end
				list:addButtonEntry("Cancel",cancel)
				MainUI:setModal(list)
				MainUI:setCancelAction(cancel)
			else
				MainUI:displayMessage("No campaign_hardfile found in the Chaoshead data directory!\nYou have to manually move it there first."
				.."\n(You can open the data direcotry in the Misc. tab.")
			end
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
	local info = love.filesystem.getInfo(self.folder)
	if not info then
		love.filesystem.createDirectory(self.folder)
	end
	for _,dirname in ipairs(love.filesystem.getDirectoryItems(self.folder)) do
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
