local LHS = Class()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--these are used when the level id is given
local userCode = "xxqtsv"
local levelsPath = require("levelhead.misc").getDataPath().."/UserData/"..userCode.."/stages/"
local extension = ".lhs"

function LHS:initialize(level)
	local t = type(level)
	if t=="number" then
		self:loadFile(levelsPath ..level.. extension)
	elseif t=="string" then
		self:loadFile(levelsPath ..level.. extension)
	elseif t=="nil" then
		self:loadDefaultFile()
	end
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
