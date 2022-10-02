local List = require("ui.layout.list")
local Version = require("utils.version")

local update = false

local UPDATE_SETTINGS_AFTER = "2.9.0"

if Version.previous and Version.previous~=Version.current then
	if Version.previous=="DEV" then
		-- we don't know what happened during development, make sure we have settings we can work with
		update = true
	elseif Version.current=="DEV" then
		--we went from release to development, assume the user knows what they're doing
		update = false
	else
		update = Version.isLessThan(Version.previous, UPDATE_SETTINGS_AFTER)
	end
-- 2.3.1 and older: version not tracked yet, but we have something else to check if this is a new installation
elseif not Version.previous and Storage.lastLevelOpened then
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
					error("Could not reset(/delete) settings file at "..path)
				end
			end
		end
		love.event.quit("restart")
	end)
	MainUI:displayMessage(l)
end