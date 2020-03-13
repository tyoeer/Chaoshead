local LHS = Class()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

local userCode = "m7n6j8"
local levelsPath = love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/"..userCode.."/stages/"
local extension = ".lhs"

function LHS:initialize(level)
	local t = type(level)
	if t=="number" then
		self.fileName = tostring(level)
	elseif t=="string" then
		self.fileName = level
	end
	self:loadFile(levelsPath ..self.fileName.. extension)
end

function LHS:loadFile(fullPath)
	local file,e = io.open(fullPath,"rb")
	print(e)
	self.raw = file:read("*a")
	file:close()
end

function LHS:getBytes(offset,length)
	return self.raw:sub(offset,offset+length-1)
end

function LHS:getNumber(offset)
	return math.bytesToNumber(self:getBytes(offset,1))
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

return LHS
