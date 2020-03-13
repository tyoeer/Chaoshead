local LHS = Class()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--these are used when the level id is given
local userCode = "m7n6j8"
local levelsPath = love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/"..userCode.."/stages/"
local extension = ".lhs"

local files = {
	love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/m7n6j8/stages/-22.lhs",
}

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

function LHS:loadDefaultFile()
	for _,v in ipairs(files) do
		local file,err = io.open(v,"rb")
		if file then
			self.raw = file:read("*a")
			file:close()
			break
		end
	end
end

function LHS:loadFile(fullPath)
	local file,err = io.open(fullPath,"rb")
	if err then error(err) end
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
