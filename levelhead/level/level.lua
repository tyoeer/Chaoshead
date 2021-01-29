local World = require("levelhead.level.world")
local Settings = require("levelhead.level.settings")

local Level = Class(World)

function Level:initialize(w,h)
	Level.super.initialize(self, w,h)
	self.settings = Settings:new()
end

return Level
