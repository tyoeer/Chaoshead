return {
	{
		label = "The following nodes are missing concrete levels:",
		---@param c Campaign
		check = function(c)
			local out = {}
			for node in c.nodes:iterate() do
				if node.type==level then
					if type(node.level)=="string" or node.level==nil then
						table.insert(out,node)
					end
				end
			end
			return out
		end,
	},
	{
		label = "The following levels are never used:",
		---@param c Campaign
		check = function(c)
			local out = {}
			for level in c.levels:iterate() do
				---@cast level Campaignlevel
				if not level.nodes:getTop() then
					table.insert(out,level)
				end
			end
			return out
		end,
	},
	{
		label = "The following levels have their CampaignMarker not set:",
		---@param c Campaign
		check = function(c)
			local out = {}
			for level in c.levels:iterate() do
				---@cast level Campaignlevel
				if level:getMetadata().campaignMarker~=true then
					table.insert(out,level)
				end
			end
			return out
		end,
	},
	{
		label = "The follwing levels don't follow the id standard:",
		---@param c Campaign
		check = function(c)
			local out = {}
			for level in c.levels:iterate() do
				---@cast level Campaignlevel
				local creatorCode, _campaignName, _type, _subid = level:idMatchStandard()
				if not creatorCode then
					table.insert(out, level)
				end
			end
			return out
		end,
	},
	{
		label = "The follwing nodes don't follow the id standard:",
		---@param c Campaign
		check = function(c)
			local out = {}
			for node in c.nodes:iterate() do
				local creatorCode, _campaignName, _type, _subid = node:idMatchStandard()
				if not creatorCode then
					table.insert(out, node)
				end
			end
			return out
		end,
	},
}
	