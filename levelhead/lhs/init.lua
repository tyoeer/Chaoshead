local LHS = Class()

--[[

It should be noted that the raw stuff uses zero as lowest value when refering to coördinates

]]--

--these are used when the level id is given
local userCode = "xxqtsv"
local levelsPath = love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/"..userCode.."/stages/"
local extension = ".lhs"

local files = {
	love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/UserData/xxqtsv/stages/-12.lhs",
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

function LHS:getNumber1(offset)
	return math.bytesToNumberLE(self:getBytes(offset,1))
end

function LHS:getNumber2(offset)
	return math.bytesToNumberLE(self:getBytes(offset,2))
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
