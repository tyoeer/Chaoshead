local Music = require("levelhead.data.music")
local Zones = require("levelhead.data.zones")
local Lang = require("levelhead.data.languages")
local Misc = require("levelhead.misc")

---@class Settings : Object
local Settings = Class("LevelSettings")

function Settings:initialize()
	---@type integer
	self.legacyVersion = 11000 --default value also used by Levelhead
	self.levelheadVersion = { -- the latest LH version as of the time of this writing
		major = 1,
		minor = 22,
		patch = 4,
	}
	self.published = false
	
	self.zone = 0 -- Tree Of Marla
	self.music = 10 -- Ambient Leveas
	self.mode = 0 -- Normal Mode
	self.minimumPlayers = 1
	self.playersSharePowerups = false
	self.weather = false
	self.language = 0 -- English
	self.multiplayerRespawnStyle = 0 -- Bubble
	self.stopCameraAtLevelSides = false
	self.title = {} -- empty title
	self.zoomLevel = 1.0
end

---@return integer major, integer minor, integer patch
function Settings:getLevelheadVersion()
	return self.levelheadVersion.major, self.levelheadVersion.minor, self.levelheadVersion.patch
end

---@param major integer
---@param minor integer
---@param patch integer
function Settings:setLevelheadVersion(major, minor, patch)
	self.levelheadVersion.major = major
	self.levelheadVersion.minor = minor
	self.levelheadVersion.patch = patch
end

function Settings:setZone(selector)
	self.zone = Zones:getID(selector)
end
---@return string
function Settings:getZone()
	return Zones:getName(self.zone)
end

function Settings:setMusic(selector)
	self.music = Music:getID(selector)
end
---@return string
function Settings:getMusic()
	return Music:getName(self.music)
end

function Settings:setLanguage(selector)
	self.music = Lang:getID(selector)
end
---@return string
function Settings:getLanguage()
	return Lang:getName(self.language)
end

local mpRespawnStyles = {
	[0] = "Bubble",
	[1] = "BUDD-E",
}
---@param selector "Bubble"|"BUDD-E"
function Settings:setMultiplayerRespawnStyle(selector)
	for k,v in pairs(mpRespawnStyles) do
		if v==selector then
			self.multiplayerRespawnStyle = k
			break
		end
	end
end
---@return "Bubble"|"BUDD-E"
function Settings:getMultiplayerRespawnStyle()
	return mpRespawnStyles[self.multiplayerRespawnStyle]
end

---@return string
function Settings:getTitle()
	return Misc.parseLevelName(self.title)
end

-- DEPRECATED old names and formats for previosuly unknown field

local prefixFormat = "<I2I4"

function Settings:__index(key)
	if key=="campaignMarker" then
		return self.published and 1 or 0
	elseif key=="prefix" then
		local lhv = Misc.encodeVersionTable(self.levelheadVersion)
		return love.data.pack("string", prefixFormat, self.legacyVersion, lhv)
	else
		rawget(self,key)
	end
end

function Settings:__newindex(key, value)
	if key=="campaignMarker" then
		self.published = value~=0
	elseif key=="prefix" then
		local legacy, lhv = love.data.unpack(prefixFormat, value)
		---@cast legacy integer as specified in the prefixFormat string
		self.legacyVersion = legacy
		---@cast lhv integer as specified in the prefixFormat string
		self.levelheadVersion = Misc.decodeVersionTable(lhv)
	else
		rawset(self,key,value)
	end
end

return Settings
