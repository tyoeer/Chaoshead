local NFS = require("libs.nativefs")

--this class represents the details of a level selected in the level selector
local UI = Class("SelectedLevelDetailsUI",require("ui.tools.details"))

function UI:initialize(workshop,data)
	self.workshop = workshop
	self.path = data.path
	self.name = data.name
	self.id = data.id
	UI.super.initialize(self)
end

function UI:onReload(list)
	list:addTextEntry("Name: ".. self.name)
	list:addTextEntry("Id:   ".. self.id)
	list:addTextEntry("path: ".. self.path)
	
	list:addButtonEntry(
		"Open in editor (load)",
		function()
			self.workshop:openEditor(self.path)
		end
	)
	list:addButtonEntry(
		"Rehash",
		function()
			local f = NFS.newFile(self.path)
			f:open("r")
			local size = f:getSize()
			local notHash = f:read(size-33)
			--local oldHash = f:read("*a"):sub(1,-1)
			--print(oldHash)
			f:close()
			f:open(self.path,"w")
			f:write(notHash)
			local hash = require("levelhead.lhs").hash(notHash)
			f:write(hash)
			f:write(string.char(0))
			f:close()
		end
	)
	--to be replaced with a seperate & mroe generic data viewing/exploration module
	--[[list:addButtonEntry(
		"Explore user data",
		function()
			local dv = require("ui.utils.dataViewer"):new(UserData.getUserData(data.user).raw)
			ui.child.child:addChild(dv)
		end
	)]]
end

return UI
