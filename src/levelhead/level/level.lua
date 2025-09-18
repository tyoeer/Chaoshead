local World = require("levelhead.level.world")
local Settings = require("levelhead.level.settings")

---@class Level : World
---@field super World
local Level = Class(World)

function Level:initialize()
	Level.super.initialize(self)
	self.settings = Settings:new()
end

return Level
