local World = require("levelhead.level.world")

local Level = Class(World)

function Level:initialize(w,h)
	
	Level.super.initialize(self, w,h)
	
end

return Level
