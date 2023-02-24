local Details = require("campaignEditor.levelDetails")
local Level = require("levelhead.campaign.level")

local UI = Class("CampaignLevelSelectorUI", require("ui.tools.treeViewer"))

function UI:initialize(root)
	self.root = root
	UI.super.initialize(self)
	self.title = "Levels"
end

function UI:getRootEntries()
	local out = {}
	
	for level in self.root.campaign.levels:iterate() do
		table.insert(out,{
			level = level,
			title = level:getLabel()
		})
	end
	
	table.sort(out, function(a,b)
		return a.title < b.title
	end)
	
	table.insert(out, 1, {
		title = "Import untracked level files",
		action = function()
			local c = self.root.campaign
			
			local has = {}
			for level in c.levels:iterate() do
				has[level.file] = true
			end
			
			local nAdded = 0
			local items = love.filesystem.getDirectoryItems(c.path .. c.SUBPATHS.levels)
			for _, file in ipairs(items) do
				if not has[file] then
					local id = file:match("(.+).lhs$")
					if id then
						local level = Level:new(id)
						c:addLevelRaw(level)
						level:loadMetadata()
						
						nAdded = nAdded + 1
						has[file] = true
					end
				end
			end
			self:reload()
			MainUI:popup(string.format("Imported %i levels",nAdded))
		end
	})
	table.insert(out, 2, {
		title = "Standardise all IDs",
		action = function()
			-- find most used creator code
			local creators = {}
			for level in self.root.campaign.levels:iterate() do
				local creatorCode = level:idMatchStandard()
				if creatorCode then
					if not creators[creatorCode] then
						creators[creatorCode] = {}
					end
					table.insert(creators[creatorCode], level)
				end
			end
			local mainCode = "AAAAAAA"
			local mostN = 0
			for code, levels in pairs(creators) do
				if #levels > mostN then
					mainCode = code
				end
			end
			
			local cName = self.root.campaign:getName()
			
			local nChanged = 0
			local nRumpus = 0
			for level in self.root.campaign.levels:iterate() do
				if not level.id:match("^chcx-") then
					local creator, levelCode = level.id:match("^(%w%w%w%w%w%w)-(%w%w%w%w%w%w%w)$")
					if creator and levelCode and not level.rumpusCode then
						level.rumpusCode = levelCode
						nRumpus = nRumpus + 1
					end
					level:setId(string.format("chcx-%s-%s-level-%s", mainCode, cName, level.id))
					nChanged = nChanged + 1
				end
			end
			
			self.root:levelChanged()
			MainUI:popup(
				"Set the IDs of "..nChanged.." levels." ..
				(mainCode=="AAAAAAA" and "\nCouldn't find a creator code, used AAAAAAA as placeholder." or "") ..
				(nRumpus==0 and "" or "\nSet the Rumpus codes of "..nRumpus.." levels.")
			)
		end
	})
	table.insert(out, 3, {
		title = "Reload all metadata",
		action = function()
			local suc = xpcall(
				function()
					for level in self.root.campaign.levels:iterate() do
						level:loadMetadata()
					end
				end,
				self.root.loadErrorHandler
			)
			if suc then
				self.root:levelChanged()
			end
		end
	})
	
	return out
end

function UI:getDetailsUI(data)
	return Details:new(self.root, data.level)
end


function UI:selectLevel(level)
	self:setDetailsUI(Details:new(self.root, level))
end


function UI:levelChanged(level)
	if not level or level==self.details.level then
		self.details:reload()
	end
end

function UI:reload()
	-- self.details starts out as a placeholder BaseUI, if it has a level it is the proper details UI
	if self.details.level then
		-- Can't use campaign:getLevel(), it errors if it doesn't find the level
		local level = self.root.campaign.levelsById[self.details.level.id]
		if level then
			self.details:reload(level)
		else
			self:resetDetails()
		end
	end
	UI.super.reload(self)
end

return UI
