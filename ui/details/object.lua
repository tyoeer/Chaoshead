local P = require("levelhead.data.properties"):new()
local E = require("levelhead.data.elements"):new()

local UI = Class(require("ui.list"))

function UI:initialize(w,h,object)
	UI.super.initialize(self,w,h)
	self.title = "Object Info"
	self:setObject(object)
end

function UI:setObject(object)
	self.object = object
	self:reload()
end

function UI:reload()
	self:resetList()
	if self.object then
		local o = self.object
		self:addTextEntry("Element: "..E:getName(o.id).." ("..o.id..")")
		self:addTextEntry("X: "..o.x)
		self:addTextEntry("Y: "..o.y)
		--properties
		if o.properties then
			self:addTextEntry("Properties:")
			for k,v in pairs(o.properties) do
				self:addTextEntry(P:getName(k).." ("..k.."): "..v,1)
			end
		end
	end
end

return UI
