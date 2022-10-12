local List = require("ui.layout.list")
local ParsedInput = require("ui.layout.parsedInput")
local Packing = require("levelhead.campaign.packing")

local folder = "campaigns/"

return {
	folder = folder,
	unpack = function(callback)
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
				Packing.unpack(folder..subpath)
				callback(subpath)
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
	end
}