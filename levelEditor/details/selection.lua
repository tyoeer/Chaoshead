local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local PUI = require("levelEditor.details.property")

local UI = Class(require("ui.tools.details"))

function UI:initialize(tracker)
	--it gets (re)loaded in setSelectionTracker
	UI.super.initialize(self,false)
	self.title = "Selection"
	
	self:setSelectionTracker(tracker)
end

function UI:setSelectionTracker(tracker)
	self.selection = tracker
	self:reload()
end

function UI:onReload(list)
	list:resetList()
	local s = self.selection
	local c = s.contents
	--counts + filters
	do
		list:addTextEntry("Tiles: "..s.mask.nTiles)
		list:addButtonEntry("Deselect",function()
			self.editor:deselect()
		end)
		if s:hasLayer("foreground") then
			list:addTextEntry("Foreground objects: "..c.nForeground)
			if c.nForeground ~= 0 then
				list:addButtonEntry("Deselect foreground layer",function()
					self.editor:removeSelectionLayer("foreground")
				end)
			end
		end
		if s:hasLayer("background") then
			list:addTextEntry("Background objects: "..c.nBackground)
			if c.nBackground ~= 0 then
				list:addButtonEntry("Deselect background layer",function()
					self.editor:removeSelectionLayer("background")
				end)
			end
		end
		if s:hasLayer("pathNodes") then
			list:addTextEntry("Path nodes: "..c.nPathNodes)
			if c.nPathNodes ~= 0 then
				list:addButtonEntry("Deselect path layer",function()
					self.editor:removeSelectionLayer("pathNodes")
				end)
			end
		end
	end
	list:addButtonEntry("Delete",function()
		self.editor:deleteSelection()
	end)
	-- info of single object
	do
		--foreground
		if c.nForeground==1 and c.nBackground==0 and c.nPathNodes==0 then
			local o = c.foreground:getTop()
			list:addTextEntry("Position: ("..o.x..","..o.y..")")
			list:addTextEntry("Element: "..o:getName().." ("..o.id..")")
			list:addTextEntry("Layer: Foreground")
			if o.contents then
				list:addTextEntry("Contents: "..o:getContents().." ("..o.contents..")")
			else
				list:addTextEntry("Contents: None")
			end
		elseif c.nForeground==0 and c.nBackground==1 and c.nPathNodes==0 then
			--background
			local o = c.background:getTop()
			list:addTextEntry("Position: ("..o.x..","..o.y..")")
			list:addTextEntry("Element: "..o:getName().." ("..o.id..")")
			list:addTextEntry("Layer: Background")
		elseif c.nForeground==0 and c.nBackground==0 and c.nPathNodes==1 then
			local n = c.pathNodes:getTop()
			--mark it as a path node to prevent possible confusion
			list:addTextEntry("Path Node Position: ("..n.x..","..n.y..")")
		end
	end
	--add a divider
	list:addTextEntry(" ",0)
	--objects with unknown properties
	do
		local u = c.unknownProperties
		if u:getTop()~=nil then
			local text = "The objects at the following positions are missing proper property data and had to use fallbacks:"
			local max = Settings.misc.selectionDetails.maxUnknownProperties
			for obj in u:iterate() do
				text = text..string.format(" (%d,%d)", obj.x, obj.y)
				max = max - 1
				if max<=0 then
					text = text.." + more"
					break
				end
			end
			list:addTextEntry(text)
		end
	end
	--properties
	for _,pl in pairs(c.properties) do
		list:addUIEntry(PUI:new(pl,list.style))
	end
end

return UI
