local UI = Class(require("ui.base.root"))

-- a replacement for base.root that doesn't give it's children access to stuff
-- used in layout.block to prevent blocked children erorring because they aren't connected

function UI:initialize(child)
	UI.super.initialize(self,child)
end

function UI:getMouseX()
	return -1
end
function UI:getMouseY()
	return -1
end


return UI
