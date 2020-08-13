local UI = Class(require("ui.structure.padding"))

function UI:initialize()
	local list = require("ui.structure.list"):new()
	
	list:addButtonEntry("Open scripts folder",function()
		local url = "file://"..love.filesystem.getSaveDirectory().."/"..require("script").folder
		love.system.openURL(url)
	end)
	
	UI.super.initialize(self,list,settings.dim.misc.padding)
	self.title = "Misc."
end

return UI
