local P = require("levelhead.data.properties")
local E = require("levelhead.data.elements")

local PUI = require("ui.level.details.property")

local UI = Class(require("ui.structure.list"))

function UI:initialize(tracker)
	UI.super.initialize(self)
	self.title = "Selection"
	
	self.entryMargin = settings.dim.editor.details.selection.entryMargin
	self.indentSize = settings.dim.editor.details.selection.textEntryIndentSize
	
	self:setSelectionTracker(tracker)
end

function UI:setSelectionTracker(tracker)
	self.selection = tracker
	self:reload()
end

function UI:reload()
	self:resetList()
	local s = self.selection
	local c = s.contents
	--counts + filters
	do
		self:addTextEntry("Tiles: "..s.mask.nTiles)
		self:addButtonEntry("Deselect",function()
			self.editor:deselect()
		end)
		if s:hasLayer("foreground") then
			self:addTextEntry("Foreground objects: "..c.nForeground)
			if c.nForeground ~= 0 then
				self:addButtonEntry("Deselect foreground layer",function()
					self.editor:removeSelectionLayer("foreground")
				end)
			end
		end
		if s:hasLayer("background") then
			self:addTextEntry("Background objects: "..c.nBackground)
			if c.nBackground ~= 0 then
				self:addButtonEntry("Deselect background layer",function()
					self.editor:removeSelectionLayer("background")
				end)
			end
		end
		if s:hasLayer("pathNodes") then
			self:addTextEntry("Path nodes: "..c.nPathNodes)
			if c.nPathNodes ~= 0 then
				self:addButtonEntry("Deselect path layer",function()
					self.editor:removeSelectionLayer("pathNodes")
				end)
			end
		end
	end
	self:addButtonEntry("Delete",function()
		self.editor:deleteSelection()
	end)
	-- info of single object
	do
		--foreground
		if c.nForeground==1 and c.nBackground==0 and c.nPathNodes==0 then
			local o = c.foreground:getTop()
			self:addTextEntry("Position: ("..o.x..","..o.y..")")
			self:addTextEntry("Element: "..o:getName().." ("..o.id..")")
			self:addTextEntry("Layer: Foreground")
			if o.contents then
				self:addTextEntry("Contents: "..o:getContents().." ("..o.contents..")")
			else
				self:addTextEntry("Contents: None")
			end
		elseif c.nForeground==0 and c.nBackground==1 and c.nPathNodes==0 then
			--background
			local o = c.background:getTop()
			self:addTextEntry("Position: ("..o.x..","..o.y..")")
			self:addTextEntry("Element: "..o:getName().." ("..o.id..")")
			self:addTextEntry("Layer: Background")
		elseif c.nForeground==0 and c.nBackground==0 and c.nPathNodes==1 then
			local n = c.pathNodes:getTop()
			--mark it as a path node to prevent possible confusion
			self:addTextEntry("Path Node Position: ("..n.x..","..n.y..")")
		end
	end
	--add a divider
	self:addTextEntry(" ",0)
	--objects with unknown properties
	do
		local u = c.unknownProperties
		if u:getTop()~=nil then
			local text = "The objects at the following positions are missing proper property data and had to use fallbacks:"
			local max = settings.misc.selectionDetails.maxUnknownProperties
			for obj in u:iterate() do
				text = text..string.format(" (%d,%d)", obj.x, obj.y)
				max = max - 1
				if max<=0 then
					text = text.." + more"
					break
				end
			end
			self:addTextEntry(text)
		end
	end
	--properties
	for _,pl in pairs(c.properties) do
		self:addUIEntry(PUI:new(pl))
	end
end

return UI
