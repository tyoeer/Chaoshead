local UserData = require("levelhead.userData")
local NFS = require("libs.nativefs")

local UI = Class(require("ui.structure.proxy"))

function UI:initialize()
	local treeData = {
		getRootEntries = function(self)
			local out = {}
			for _,code in ipairs(UserData.getUserCodes()) do
				table.insert(out,{
					title = code,
					code = code,
					folder = true,
				})
			end
			return out
		end,
		getChildren = function(self,parent)
			local out = {}
			for _,level in ipairs(UserData.getUserData(parent.code):getWorkshopLevels()) do
				table.insert(out,{
					raw = level,
					user = parent.code,
					title = level.name,
					folder = false,
				})
			end
			return out
		end,
		getDetailsUI = function(self,data)
			--this should probably be it's own class, but I couldn't come up with a name for it here we are
			--besides when I started it wasn't very complex (thoguh that might have changed)
			local list = require("ui.structure.list"):new()
			
			local d = data.raw
			list:addTextEntry("Name: ".. d.name)
			list:addTextEntry("Id:   ".. d.id)
			list:addTextEntry("path: ".. d.path)
			
			list:addButtonEntry(
				"Open in editor (load)",
				function()
					ui:openEditor(d.path)
				end
			)
			list:addButtonEntry(
				"Rehash",
				function()
					local f = NFS.newFile(d.path)
					f:open("r")
					local size = f:getSize()
					local notHash = f:read(size-33)
					--local oldHash = f:read("*a"):sub(1,-1)
					--print(oldHash)
					f:close()
					f:open(d.path,"w")
					f:write(notHash)
					local hash = require("levelhead.lhs").hash(notHash)
					f:write(hash)
					f:write(string.char(0))
					f:close()
				end
			)
			list:addButtonEntry(
				"Explore user data",
				function()
					local dv = require("ui.utils.dataViewer"):new(UserData.getUserData(data.user).raw)
					ui.child.child:addChild(dv)
				end
			)
			
			return require("ui.structure.padding"):new(list,settings.dim.levelSelector.details.padding)
		end,
	}
	local treeViewer = require("ui.utils.treeViewer"):new(treeData)
	treeViewer.child:setDivisionRatio(settings.dim.levelSelector.listDetailsDivisionRatio)
	UI.super.initialize(self,treeViewer)
	self.title = "Level Select"
end

return UI
