local UI = Class(require("ui.worldViewer"))
local DET_OBJ = require("ui.details.object")

function UI:initialize(w,h,level,editor)
	UI.super.initialize(self,w,h,level)
	self.title = "World Editor"
	self.editor = editor
end

function UI:mousepressed(x,y,button,isTouch)
	if button==1 then
		local tileX, tileY = self:getMouseTile()
		local obj = self.level.foreground:get(tileX,tileY)
		if obj then
			self.editor:addTab(DET_OBJ:new(-1,-1,obj))
		end
	end
end

return UI
