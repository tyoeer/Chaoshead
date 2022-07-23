local PUI = require("levelEditor.details.property")
local PEDIT = require("levelEditor.details.propertyEditor")

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

function UI:formatPosition(o,at)
	if at==nil then
		at = true
	end
	if at then
		return string.format(" at (%d,%d)", o.x, o.y)
	else
		return string.format("(%d,%d)", o.x, o.y)
	end
end

function UI:formatElement(obj)
	if Settings.misc.editor.showRawNumbers then
		return string.format("element: %s (%d)", obj:getName(), obj.id)
	else
		return string.format("element: %s", obj:getName())
	end
end

function UI:onReload(list)
	list:resetList()
	local s = self.selection
	local c = s.contents
	--counts + filters
	do
		list:addTextEntry("Tiles: "..s.mask.nTiles)
		list:addButtonEntry("Deselect all",function()
			self.editor:deselectAll()
		end)
		if s:hasLayer("foreground") then
			local text = string.format("Deselect foreground (%d object%s)", c.nForeground, c.nForeground==1 and "" or "s")
			list:addButtonEntry(text, function()
				self.editor:removeSelectionLayer("foreground")
			end)
		end
		if s:hasLayer("background") then
			local text = string.format("Deselect background (%d object%s)", c.nBackground, c.nBackground==1 and "" or "s")
			list:addButtonEntry(text, function()
				self.editor:removeSelectionLayer("background")
			end)
			-- list:addTextEntry("Background objects: "..c.nBackground)
			-- if c.nBackground ~= 0 then
			-- 	list:addButtonEntry("Deselect background layer",function()
			-- 		self.editor:removeSelectionLayer("background")
			-- 	end)
			-- end
		end
		if s:hasLayer("pathNodes") then
			local text = string.format("Deselect path nodes (%d node%s)", c.nPathNodes, c.nPathNodes==1 and "" or "s")
			list:addButtonEntry(text, function()
				self.editor:removeSelectionLayer("pathNodes")
			end)
		end
	end
	--add a divider
	list:addTextEntry(" ",0)
	
	-- info & co
	list:addButtonEntry("Delete",function()
		self.editor:deleteSelection()
	end)
	if c.nPathNodes >= 2 then
		list:addButtonEntry(
			"Disconnect path nodes",
			function()
				self.editor:disconnectNodes()
			end
		)
	end
	do -- single object info
		if s.mask.nTiles==1 then
			local t = s.mask.tiles:getTop()
			list:addTextEntry("Position: "..self:formatPosition(t, false))
		end
		--foreground
		if c.nForeground==1 then
			local o = c.foreground:getTop()
			
			local elem = "Foreground "..self:formatElement(o)
			if s.mask.nTiles ~= 1 then
				elem = elem .. self:formatPosition(o, true)
			end
			list:addTextEntry(elem)
			-- list:addTextEntry("Layer: Foreground")
			if o.contents then
				if Settings.misc.editor.showRawNumbers then
					list:addTextEntry("Contents: "..o:getContents().." ("..o.contents..")")
				else
					list:addTextEntry("Contents: "..o:getContents())
				end
			else
				list:addTextEntry("Contents: None")
			end
		end
		if c.nBackground==1 then
			--background
			local o = c.background:getTop()
			
			local elem = "Background "..self:formatElement(o)
			if s.mask.nTiles ~= 1 then
				elem = elem .. self:formatPosition(o, true)
			end
			list:addTextEntry(elem)
			-- list:addTextEntry("Layer: Background")
		end
		if c.nPathNodes==1 and s.mask.nTiles~=1 then
			local n = c.pathNodes:getTop()
			--mark it as a path node to prevent possible confusion
			list:addTextEntry("Path Node position: ("..n.x..","..n.y..")")
		end
		if c.nPathNodes==1 then
			local n = c.pathNodes:getTop()
			if n.next and (n.next~=n) then
				local dx = n.next.x - n.x
				local dy = n.next.y - n.y
				local a = math.atan2(dy,dx)/math.pi*4
				local dir = "$Error"
				if a >= 3.5 then
					dir = "left"
				elseif a > 2.5 then
					dir = "down left"
				elseif a >= 1.5 then
					dir = "down"
				elseif a > 0.5 then
					dir = "down right"
				elseif a >= -0.5 then
					dir = "right"
				elseif a > -1.5 then
					dir = "up right"
				elseif a >= -2.5 then
					dir = "up"
				elseif a > -3.5 then
					dir = "up left"
				elseif a >= -4.5 then
					dir = "left"
				end
				list:addTextEntry("Path direction: "..dir)
			elseif n.path.tail==n then
				list:addTextEntry("Path direction: end node")
			end
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
		list:addButtonEntry(PUI:new(pl,list.style),function()
			MainUI:displayMessage(PEDIT:new(pl, self.editor))
		end)
	end
end

return UI
