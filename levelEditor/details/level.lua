local UI = Class("LevelDetailsUI",require("ui.tools.details"))

local levelSettings = {
	--{index into the Settings, display label, don't include raw ID}
	--third option is only used once, but making a special case for title in the handling code is worse
	{"getTitle","Title",true},
	{"getZone","Zone"},
	{"getMusic","Music"},
	{"weather","Weather"},
	{"minimumPlayers","Minimum Players"},
	{"playerSharePowerups","Player Share Powerups"},
	{"getMultiplayerRespawnStyle","Multiplayer Respawn Style"},
	{"stopCameraAtLevelSides","Stop Camera At Level Sides"},
	{"getLanguage","Language"},
}

function UI:initialize(level,editor)
	self.editor = editor
	self.level = level
	UI.super.initialize(self)
	self.title = "Level Info"
end

function UI:onReload(list,level)
	if level then
		self.level = level
	else
		level = self.level
	end
	list:resetList()
	
	list:addButtonEntry(
		"Save Level",
		function()
			self.editor.root:save()
		end
	)
	list:addButtonEntry(
		"Reload Level",
		function()
			self.editor.root:reload()
		end
	)
	list:addButtonEntry(
		"Close editor (without saving)",
		function()
			self.editor.root:close()
		end
	)
	
	list:addTextEntry(" ") -- seperator
	
	list:addButtonEntry(
		"Check level limits",
		function()
			if self.editor.root:checkLimits() then
				MainUI:displayMessage("Level doesn't break any limits!")
			end
		end
	)
	list:addTextEntry("Width:  "..level:getWidth())
	list:addTextEntry("Height: "..level:getHeight())
	-- settings
	list:addTextEntry("Level settings:")
	for _, v in ipairs(levelSettings) do
		local data = level.settings[v[1]]
		if type(data)=="function" then
			if v[3] or Settings.misc.editor.showRawNumbers==false then
				list:addTextEntry(v[2]..":  "..data(level.settings),1)
			else
				list:addTextEntry(v[2]..":  "..data(level.settings).." ("..level.settings[v[1]:sub(4):gsub("^.", string.lower)]..")",1)
			end
		elseif type(data)=="number" then
			list:addTextEntry(v[2]..":  "..data,1)
		elseif type(data)=="boolean" then
			if Settings.misc.editor.showRawNumbers then
				list:addTextEntry(v[2]..":  "..(data and "Yes" or "No").." ("..(data and 1 or 0)..")",1)
			else
				list:addTextEntry(v[2]..":  "..(data and "Yes" or "No"),1)
			end
		end
	end
end

return UI
