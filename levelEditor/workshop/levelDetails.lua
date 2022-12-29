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
	list:resetList()
	
	local info = NFS.getInfo(self.path)
	if not info then
		list:addTextEntry("Level "..self.name.." got deleted")
		return
	end
	
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
			local function err(mes)
				MainUI:displayMessage(
					"Error while rehashing, file might be corrupted",
					mes
				)
			end
			local f = NFS.newFile(self.path)
			local suc, mes = f:open("r")
			if not suc then return err(mes) end
			local size = f:getSize()
			local notHash = f:read(size-33)
			--local oldHash = f:read("*a"):sub(1,-1)
			--print(oldHash)
			local suc, mes = f:close()
			if not suc then return err(mes) end
			local suc, mes = f:open("w")
			if not suc then return err(mes) end
			local suc, mes = f:write(notHash)
			if not suc then return err(mes) end
			local hash = require("levelhead.lhs").hash(notHash)
			local suc, mes = f:write(hash)
			if not suc then return err(mes) end
			local suc, mes = f:write(string.char(0))
			if not suc then return err(mes) end
			local suc, mes = f:close()
			if not suc then return err(mes) end

			MainUI:displayMessage("Succesfully rehashed level")
		end
	)
	
	list:addSeparator(false)
	
	list:addButtonEntry(
		"Show in file explorer",
		function()
			love.system.openURL("file://"..self.path:match("^(.*)/[^/\\]+$"))
		end
	)
end

function UI:onFocus(focus)
	if focus then
		self:reload()
	end
end

return UI
