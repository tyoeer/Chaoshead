local LIST = require("ui.layout.list")
local PADDING = require("ui.layout.padding")
local JSON = require("libs.json")

local UI = Class("DataViewerUI",require("ui.tools.treeViewer"))

function UI:initialize(data)
	UI.super.initialize(self,{
		data = data,
		getDetailsUI = function(self,data)
			local list = LIST:new(5,10)
			
			
			if type(data.raw)=="string" then
				if data.raw:len()>500 then
					list:addTextEntry("Value is too long to display: "..data.raw:len())
				else
					list:addTextEntry("Value: ".. data.raw)
				end
				list:addTextEntry("Type (Lua):   ".. type(data.raw))
				list:addButtonEntry(
					"Try parsing as JSON",
					function()
						local dat = JSON.decode(data.raw)
						local dv = UI:new(dat)
						ui.child.child:addChild(dv)
					end,
					5
				)
			else
				list:addTextEntry("Value: ".. data.raw)
				list:addTextEntry("Type (Lua):   ".. type(data.raw))
			end
			
			return PADDING:new(list,5)
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
