local List = require("ui.layout.list")

local update = false

local function parseVersion(str)
	local out = {}
	local i=1
	for part in str:gmatch("([^%.])") do
		out[i] = tonumber(part)
		i = i + 1
	end
	return out
end
local function isHigherEquals(a,b)
	for i,v in ipairs(a) do
		if v > b[i] then
			return true
		elseif v < b[i] then
			return false
		end
	end
	return true
end

local UPDATE_SETTINGS_AFTER = "2.3.1"

local old = Storage.version
Storage.version = VERSION
Storage.save()

if old and old~=VERSION then
	if old=="DEV" then
		update = true
	else
		local old = parseVersion(old)
		local after = parseVersion(UPDATE_SETTINGS_AFTER)
		update = isHigherEquals(after,old)
	end
-- 2.3.1 and older: version not tracked yet, but we have something else to check if this is a new installation
elseif not old and Storage.lastLevelOpened then
	update = true
end

if update then
	local l = List:new(Settings.theme.modal.listStyle)
	l:addTextEntry("The default settings have changed significantly in this update, reset your settings to the default? (Will restart)")
	l:addButtonEntry("Reset all settings + restart",function()
		for _,file in ipairs(love.filesystem.getDirectoryItems(Settings.folder)) do
			local path = Settings.folder..file
			local real = love.filesystem.getRealDirectory(path)
			if real:match(love.filesystem.getSaveDirectory()) then
				if not love.filesystem.remove(path) then
					error("Could not reset(/delete) settings file: "..path)
				end
			end
		end
		love.event.quit("restart")
	end)
	MainUI:displayMessage(l)
end