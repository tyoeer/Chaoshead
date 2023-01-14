local Details = require("ui.tools.details")
local JSON = require("libs.json")

local UI = Class("TableViewerUI",require("ui.tools.treeViewer"))

function UI:initialize(data,overview)
	self.data = data
	self.overview = overview
	UI.super.initialize(self)
	self.persistant = nil -- which data we display differs, no sense remembering specific entries
	self.title = "Table Viewer"
end

local function hasTable(table)
	for _,v in pairs(table) do
		if type(v)=="table" then
			return true
		end
	end
	return false
end

function UI:genList(t, path)
	local out = {}
	for k,v in pairs(t) do
		table.insert(out,{
			title = k,
			folder = type(v)=="table" and hasTable(v),
			path = path..k,
			raw = v,
		})
	end
	
	table.sort(out, function(a,b)
		return a.title < b.title
	end)
	
	return out
end

function UI:getRootEntries()
	local out = self:genList(self.data, "")
	
	table.insert(out, 1, {
		title = "Close viewer",
		action = function()
			self.overview:closeViewer(self)
		end
	})
	
	return out
end

function UI:getChildren(node)
	return self:genList(node.raw, node.path..".")
end

function UI:format(val)
	if type(val)=="string" then
		if val:match("^%a%w*$") then
			return val
		else
			return string.format("%q", val)
		end
	else
		return tostring(val)
	end
end

function UI:getDetailsUI(data)
	local details = Details:new(false)
	local list = details:getList()
	
	local t = type(data.raw)
	if t=="string" then
		if data.raw:len() > Settings.misc.dataExplorer.maxDisplayStringLength then
			list:addTextEntry("String: too long to display!")
		else
			list:addTextEntry("String:")
			list:addTextEntry(data.raw)
		end
		if data.raw:match("^[{[]") then
			list:addButtonEntry("Try parsing as JSON", function()
				local success, dataOrErr = pcall(JSON.decode, data.raw)
				if success then
					self.overview:openDataViewer(dataOrErr, self.title.."@"..data.path)
				else
					MainUI:popup("Failed parsing as JSON:", dataOrErr)
				end
			end)
		end
	elseif t=="table" then
		local sorted = {}
		local isSequence = true
		for key, value in pairs(data.raw) do
			if type(key)~="number" or math.floor(key)~=key then
				isSequence = false
			end
			table.insert(sorted, {
				key = key,
				value = value
			})
		end
		if #sorted ~= #data.raw then
			isSequence = false
		end
		
		if isSequence then
			list:addTextEntry("List:")
			for _,v in ipairs(data.raw) do
				list:addTextEntry(self:format(v), 1)
			end
		else
			table.sort(sorted, function(a,b)
				return a.key < b.key
			end)
			list:addTextEntry("Map:")
			for _,entry in ipairs(sorted) do
				local key = self:format(entry.key)
				if not key:match("^%a%w+$") then
					key = "["..key.."]"
				end
				list:addTextEntry(key..": "..self:format(entry.value), 1)
			end
		end
	else
		list:addTextEntry(type(data.raw)..":")
		list:addTextEntry(tostring(data.raw))
	end
	
	return details
end

return UI
