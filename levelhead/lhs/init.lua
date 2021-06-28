local LHS = Class()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--which id correspodns to which setting
LHS.settingsList = {
	[0] = "music",
	"mode",
	"minimumPlayers",
	"playerSharePowerups",
	"weather",
	"language",
	"multiplayerRespawnStyle",
	"stopCameraAtLevelSides"
}
--whether or not a certain settings list id has a boolean value
LHS.settingsListBooleans = {
	[0] = false,
	false,
	false,
	true,
	true,
	false,
	false,
	true,
}

function LHS:initialize(path)
	self:loadFile(path)
end

--load the other files
local thisPath = select(1,...)
local function load(file)
	for k,v in pairs(require(thisPath.."."..file)) do
		LHS[k] = v
	end
end

load("read")
load("parse")
load("serialize")
load("write")

return LHS
