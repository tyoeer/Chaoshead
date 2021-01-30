local UI = Class("TreeViewerUI",require("ui.utils.treeViewer"))

function UI:initialize(data)
	UI.super.initialize(self,{
		data = data,
		getDetailsUI = function(self,data)
			local list = require("ui.structure.list"):new()
			
			
			if type(data.raw)=="string" then
				if data.raw:len()>500 then
					list:addTextEntry("Value is too lnog to display: "..data.raw:len())
				else
					list:addTextEntry("Value: ".. data.raw)
				end
				list:addTextEntry("Type (Lua):   ".. type(data.raw))
				list:addButtonEntry(
					"Try parsing as JSON",
					function()
						local dat = require("libs.json").decode(data.raw)
						local dv = require("ui.utils.dataViewer"):new(dat)
						ui.child:addChild(dv)
					end
				)
			else
				list:addTextEntry("Value: ".. data.raw)
				list:addTextEntry("Type (Lua):   ".. type(data.raw))
			end
			
			return require("ui.structure.padding"):new(list,5)
		end,
		getRootEntries = function(self)
			local out = {}
			for k,v in pairs(self.data) do
				table.insert(out,{
					title = k,
					folder = type(v)=="table",
					raw = v,
				})
			end
			return out
		end,
		getChildren = function(self,node)
			local out = {}
			for k,v in pairs(node.raw) do
				table.insert(out,{
					title = k,
					folder = type(v)=="table",
					raw = v,
				})
			end
			return out
		end,
	})
	self.title = "Data Explorer"
end

return UI
