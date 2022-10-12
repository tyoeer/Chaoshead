local List = require("ui.layout.list")
local ParsedInput = require("ui.layout.parsedInput")
local Packing = require("levelhead.campaign.packing")

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
	MainUI:displayMessage("Failed to pack/unpack campaign!","Error message: "..message,trace)
end

local function unpack(callback)
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
			local success = xpcall(function()
				Packing.unpack(folder..subpath)
			end, errorHandler)
			MainUI:displayMessage("Successfully unpacked campaign!")
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
		MainUI:displayMessage("No campaign_hardfile found in the Chaoshead data directory!\nYou have to manually move it there first."
		.."\n(You can open the data direcotry in the Misc. tab.")
	end
end


local function actualPack(fromPath, callback)
	local success = xpcall(function()
		Packing.pack(fromPath)
	end, errorHandler)
	MainUI:displayMessage("Succesfully packed campaign!")
	if callback then
		callback(success)
	end
end

local function pack(fromPath, callback)
	local info = love.filesystem.getInfo("campaign_hardfile")
	if info then
		local list = List:new(Settings.theme.modal.listStyle)
		list:addTextEntry("There already exists a campaign_hardfile in the Chaoshead data directory, do you want to overwrite it?")
		list:addButtonEntry("Yes/Overwrite", function()
			MainUI:removeModal()
			actualPack(fromPath, callback)
		end)
		
		local cancel = function()
			MainUI:removeModal()
		end
		list:addButtonEntry("No/Cancel",cancel)
		MainUI:setModal(list)
		MainUI:setCancelAction(cancel)
	else
		actualPack(fromPath, callback)
	end
end

return {
	folder = folder,
	unpack = unpack,
	pack = pack,
}