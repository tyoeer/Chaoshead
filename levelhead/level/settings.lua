local Music = require("levelhead.data.music")
local Zones = require("levelhead.data.zones")
local Lang = require("levelhead.data.languages")
local Misc = require("levelhead.misc")

local Settings = Class()



function Settings:initialize()
	self.prefix = string.rep(string.char(0x00),6)
	self.campaignMarker = 0
	
	self.zone = 0 -- Tree Of Marla
	self.music = 10 -- Ambient Leveas
	self.mode = 0 -- Normal Mode
	self.minimumPlayers = 1
	self.playersSharePowerups = false
	self.weather = false
	self.language = 0 -- English
	self.multiplayerRespawnStyle = 0 -- Bubble
	self.cameraHorizontalBoundary = false
	self.title = {} -- empty title
end


function Settings:setZone(selector)
	self.zone = Zones:getID(selector)
end
function Settings:getZone()
	return Zones:getName(self.zone)
end

function Settings:setMusic(selector)
	self.music = Music:getID(selector)
end
function Settings:getMusic()
	return Music:getName(self.music)
end

function Settings:setLanguage(selector)
	self.music = Lang:getID(selector)
end
function Settings:getLanguage()
	return Lang:getName(self.language)
end

local mpRespawnStyles = {
	[0] = "Bubble",
	[1] = "BUDD-E",
}
function Settings:setMultiplayerRespawnStyle(selector)
	for k,v in pairs(mpRespawnStyles) do
		if v==selector then
			self.multiplayerRespawnStyle = k
			break
		end
	end
end
function Settings:getMultiplayerRespawnStyle()
	return mpRespawnStyles[self.multiplayerRespawnStyle]
end

function Settings:getTitle()
	return Misc.parseLevelName(self.title)
end

return Settings
