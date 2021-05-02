local UI = Class("LevelDetails",require("ui.structure.list"))

local levelSettings = {
	--{index into the Settings, display label, don't include raw ID}
	--third option is only used once, but makes a special case for title in the handling code is worse
	{"getTitle","Title",true},
	{"getZone","Zone"},
	{"getMusic","Music"},
	{"weather","Weather"},
	{"minimumPlayers","Minimum Players"},
	{"playerSharePowerups","Player Share Powerups"},
	{"multiplayerRespawnStyle","Multiplayer Respawn Style"},
	{"stopCameraAtLevelSides","Stop Camera At Level Sides"},
	{"getLanguage","Language"},
}

function UI:initialize(level,editor)
	self.editor = editor
	UI.super.initialize(self)
	self.title = "Level Info"
	
	self.entryMargin = settings.dim.editor.details.level.entryMargin
	self.indentSize = settings.dim.editor.details.level.textEntryIndentSize
	
	self:reload(level)
end

function UI:reload(level)
	self:resetList()
	
	self:addTextEntry("Width:  "..level:getWidth())
	self:addTextEntry("Height: "..level:getHeight())
	self:addButtonEntry(
		"Save Level",
		function()
			self.editor.root:save()
		end,
		settings.dim.editor.details.level.buttonPadding
	)
	self:addButtonEntry(
		"Reload Level",
		function()
			self.editor.root:reload()
		end,
		settings.dim.editor.details.level.buttonPadding
	)
	self:addButtonEntry(
		"Close editor (without saving)",
		function()
			self.editor.root:close()
		end,
		settings.dim.editor.details.level.buttonPadding
	)
	self:addButtonEntry(
		"Check level limits",
		function()
			if self.editor.root:checkLimits() then
				ui:displayMessage("Level doesn't break any limits!")
			end
		end,
		settings.dim.editor.details.level.buttonPadding
	)
	-- settings
	self:addTextEntry("Level settings:")
	for _, v in ipairs(levelSettings) do
		data = level.settings[v[1]]
		if type(data)=="function" then
			if v[3] then
				self:addTextEntry(v[2]..": "..data(level.settings),1)
			else
				self:addTextEntry(v[2]..": "..data(level.settings).." ("..level.settings[v[1]:sub(4):lower()]..")",1)
			end
		elseif type(data)=="number" then
			self:addTextEntry(v[2]..": "..data,1)
		elseif type(data)=="boolean" then
			self:addTextEntry(v[2]..": "..(data and "Yes" or "No"),1)
		end
	end
	
	self:minimumHeightChanged()
end

return UI
