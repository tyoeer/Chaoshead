local LHS = Class()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--the appropriate format for string.pack for how the .lhs encodes it floats
LHS.floatFormat = "<f"
-- f is defined as a float with "native size", which I think is system-dependent, so a sanity check
assert(love.data.getPackedSize(LHS.floatFormat)==4,"Floats are not four bytes, float reading/decoding won't work!")
--which id corresponds to which setting
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
-- The byte at the start of each section in the file
LHS.tags = {
	singleForeground = 0x0D,
	foregroundRows = 0x13,
	foregroundColumns = 0x0B,
	properties = 0x63,
	repeatedPropertySets = 0x43,
	containedObjects = 0x3A,
	paths = 0x15,
	singleBackground = 0x19,
	backgroundRows = 0x1B,
	backgroundColumns = 0x0D,
	hash = 0x61,
}


function LHS:initialize(path)
	self:loadFile(path)
	self.rawContentEntries = {}
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
