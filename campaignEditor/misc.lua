local List = require("ui.layout.list")
local ParsedInput = require("ui.widgets.parsedInput")
local Packing = require("levelhead.campaign.packing")
local LhMisc = require("levelhead.misc")

local folder = "campaigns/"
local errorHandler = function(message)
	message = tostring(message)
	--part of snippet yoinked from default löve error handling
	local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
	print(message)
	print(fullTrace)
	--cut of the part of the trace that goes into the code that calls UI:openEditor()
	local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
	local trace = fullTrace:sub(1,index-1)
	MainUI:popup("Failed to pack/unpack campaign!","Error message: "..message,trace)
end

local function unpack(callback)
	local info = love.filesystem.getInfo("campaign_hardfile")
	if info then
		local list = List:new(Settings.theme.modal.listStyle)
		list:addTextEntry("Unpacks the campaign_hardfile in the Chaoshead data directory into a new folder")
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
				MainUI:popup("The path you entered was invalid!")
				return
			end
			local success = xpcall(function()
				Packing.unpack(folder..subpath)
			end, errorHandler)
			MainUI:popup("Successfully unpacked campaign!")
			if callback then
				callback(subpath, success)
			end
		end)
		local cancel = function()
			MainUI:removeModal()
		end
		list:addButtonEntry("Cancel",cancel)
		MainUI:setModal(list)
		MainUI:setCancelAction(cancel)
	else
		MainUI:popup("No campaign_hardfile found in the Chaoshead data directory!\nYou have to manually move it there first."
		.."\n(You can open the data directory in the Misc. tab.)")
	end
end


local function actualPack(fromPath, toName, callback)
	local success = xpcall(function()
		Packing.pack(fromPath, toName)
	end, errorHandler)
	if success then
		MainUI:popup("Succesfully packed campaign!")
	end
	if callback then
		callback(success)
	end
end

local function pack(fromPath, callback, toName)
	toName = toName or "campaign_hardfile"
	local info = love.filesystem.getInfo(toName)
	if info then
		local list = List:new(Settings.theme.modal.listStyle)
		list:addTextEntry("There already exists a "..toName.." in the Chaoshead data directory, do you want to overwrite it?")
		list:addButtonEntry("Yes/Overwrite", function()
			MainUI:removeModal()
			actualPack(fromPath, toName, callback)
		end)
		
		local cancel = function()
			MainUI:removeModal()
		end
		list:addButtonEntry("No/Cancel",cancel)
		MainUI:setModal(list)
		MainUI:setCancelAction(cancel)
	else
		actualPack(fromPath, toName, callback)
	end
end

local TMP_NAME = "campaign_hardfile_tmp"

local function packAndMove(fromPath, callback)
	pack(fromPath, function(suc)
		if not suc then
			if callback then
				callback(suc)
			end
		else
			local lhCampaignPath = LhMisc:getInstallationPath().."campaign_hardfile"
			local success, err = os.remove(lhCampaignPath)
			if err then
				MainUI:popup("Failed removing old campaign (tempfile still exists):", err)
			end
			local success, err = os.rename(
				love.filesystem.getSaveDirectory().."/"..TMP_NAME,
				lhCampaignPath
			)
			if err then
				MainUI:popup("Failed moving tempfile to LH directory (tempfile still exists):", err)
			end
			if callback then
				callback(success)
			end
		end
	end, TMP_NAME)
end

return {
	folder = folder,
	unpack = unpack,
	pack = pack,
	packAndMove = packAndMove,
}