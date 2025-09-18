local List = require("ui.layout.list")
local Version = require("utils.version")
local LhMisc = require("levelhead.misc")
local NFS = require("libs.nativefs")
local Github = require("utils.github")
local Button = require("ui.widgets.button")

---@return boolean|nil noPopupShown true if no pop-up was shown
local checkForUpdate = function(force)
	if Version.current=="DEV" and not force then
		return true
	end
	if Storage.lastUpdateCheck and not force then
		local diff = os.difftime(os.time(), Storage.lastUpdateCheck)
		-- diff is seconds since last update
		if diff < Settings.misc.checkForUpdatesEveryXHours*60*60 then
			return true -- Too early to check, don't spam GitHub
		end
	end
	
	Storage.lastUpdateCheck = os.time()
	Storage:save()
	
	local success, release = xpcall(Github.latestRelease, function(message)
		if message:find("getError()") then
			local err = Github.getError()
			MainUI:popup(
				"Error fetching update news:",
				"Server returned status code "..tostring(err.code),
				"Internal error message: "..message,
				"Server returned:",
				tostring(err.body)
			)
		else
			--part of snippet yoinked from default löve error handling
			local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
			--cut of the part of the trace that goes into the code that calls UI:openEditor()
			local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
			local trace = fullTrace:sub(1,index-1)
			MainUI:popup(
				"Error fetching update news:",
				message,
				trace
			)
		end
	end)
	if not success then
		return
	end

	if not release then
		MainUI:popup("Found no release on GitHub when checking for updates, which is weird, and suggests something is broken.")
	else
		local ver = release.tag_name:gsub("^v","")

		local comp = Version.compareStrings(Version.current, ver)
		if comp==-1 then
			--release version is higher: update available
			MainUI:popup(
				"A new chaoshead update is available!",
				"Current version: "..Version.current,
				"Available: "..ver,
				Button:new("Open in browser", function()
					love.system.openURL(release.html_url)
				end, Settings.theme.modal.listStyle.buttonStyle)
			)
		elseif comp==1 then
			--release version is lower: WHAT
			MainUI:popup(
				"Current version is "..Version.current..", while the latest release is "..ver..", which is lower.",
				"This is very weird, and not supposed to happen. Please get in touch so I can figure out what went wrong."
			)
		else
			return true
		end
	end
end

local checks = {
	-- Check to reset settings
	function()
		local update = false
		
		local UPDATE_SETTINGS_AFTER = "2.21.0"
		
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
			MainUI:popup(
				"The default settings have changed significantly in this update, reset your settings to the default? (Will restart)",
				{"Reset all settings + restart", function()
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
				end}
			)
		end
	end,
	
	-- No Levelhead data found
	function()
		local dataPath = LhMisc.getDataPath()
		if dataPath then
			if not NFS.getInfo(dataPath,"directory") then
				MainUI:popup(
					"Could not find Levelhead data at "..LhMisc.getDataPath(),
					"If you're doing something weird, specify a custom path using the misc. setting levelheadDataPath."
				)
			end
		else
			MainUI:popup(
				"Could not automatically find the Levelhead data folder.",
				"Some stuff will no longer work, and certain actions will crash Chaoshead.",
				"Please specify a custom path using the misc. setting levelheadDataPath."
			)
		end
	end,
	
	-- New update
	checkForUpdate,
	
	-- New user intro
	function()
		if not Storage.shownIntro then
			MainUI:popup(
				"Looks like you're new to using Chaoshead. Consider visiting the Misc. tab to:\n"
				.."- View a list of all the keybinds\n"
				.."- Patch Levelhead so you don't have to restart it to load a level edited in Chaoshead\n"
				.."- Generate a colored theme for Chaoshead"
			)
			Storage.shownIntro = true
			Storage:save()
		end
	end
}


for _,check in ipairs(checks) do
	check()
end

return {
	checkForUpdate = checkForUpdate
}