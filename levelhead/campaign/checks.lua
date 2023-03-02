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
		label = "The following level nodes are missing level data:",
		---@param c Campaign
		check = function(c)
			local out = {}
			
			local toCheck = {
				"onTimeDelivery",
				"scale",
				"weather",
				"zoneId",
				"hasGr17",
				"hasBugs",
			}
			
			for node in c.nodes:iterate() do
				if node.type=="level" then
					local missing = "Missing "
					for _,prop in ipairs(toCheck) do
						if node[prop]==nil then
							missing = missing..prop..", "
						end
					end
					if missing ~= "Missing " then
						table.insert(out, {missing:gsub(", $",":"), node})
					end
				end
			end
			
			return out
		end
	},
	
	{
		label = "The following levels don't follow the id standard:",
		---@param c Campaign
		check = function(c)
			local out = {}
			local cName = c:getName()
			local creators = {}
			for level in c.levels:iterate() do
				---@cast level Campaignlevel
				local creatorCode, campaignName, type, _subid = level:idMatchStandard()
				if not creatorCode then
					table.insert(out, {"Doesn't follow id format:", level})
				else
					if not creators[creatorCode] then
						creators[creatorCode] = {}
					end
					table.insert(creators[creatorCode], level)
				end
				if campaignName and campaignName~=cName then
					table.insert(out, {"Doesn't follow campaign name "..cName, level})
				end
				if type and type~="level" then
					table.insert(out, {"Level should use type level, but uses "..type, level})
				end
			end

			local mainCode
			local mostN = 0
			for code, levels in pairs(creators) do
				if #levels > mostN then
					mainCode = code
				end
			end
			for code, levels in pairs(creators) do
				if code~=mainCode then
					for _, level in ipairs(levels) do
						table.insert(out, {"Node differs from main creator code "..mainCode..": "..code, level})
					end
				end
			end


			return out
		end,
	},
	{
		label = "The following nodes don't follow the id standard:",
		---@param c Campaign
		check = function(c)
			local out = {}
			local cName = c:getName()
			local creators = {}
			for node in c.nodes:iterate() do
				local creatorCode, campaignName, type, _subid = node:idMatchStandard()
				if not creatorCode then
					table.insert(out, {"Doesn't follow id format:", node})
				else
					if not creators[creatorCode] then
						creators[creatorCode] = {}
					end
					table.insert(creators[creatorCode], node)
				end
				if campaignName and campaignName~=cName then
					table.insert(out, {"Doesn't follow campaign name "..cName, node})
				end
				if type then
					if node.type=="level" and type~="levelNode" then
						table.insert(out, {"Level node should use type levelNode, but uses "..type, node})
					end
					if node.type=="icon pack" and type~="vendrNode" then
						table.insert(out, {"VENDR node should use type vendrNode, but uses "..type, node})
					end
					if node.type=="presentation" and type~="presNode" then
						table.insert(out, {"Presentation node should use type presNode, but uses "..type, node})
					end
					if node.type=="path" and type~="pathNode" then
						table.insert(out, {"Path node should use type presNode, but uses "..type, node})
					end
				end
			end
			
			local mainCode
			local mostN = 0
			for code, nodes in pairs(creators) do
				if #nodes > mostN then
					mainCode = code
				end
			end
			for code, nodes in pairs(creators) do
				if code~=mainCode then
					for _, node in ipairs(nodes) do
						table.insert(out, {"Node differs from main creator code "..mainCode..": "..code, node})
					end
				end
			end
			
			
			return out
		end,
	},
	
	{
		label = "The campaign uses a campaign version different from 2299, this is untested:",
		---@param c Campaign
		check = function(c)
			if c.campaignVersion~=2299 then
				return {tostring(c.campaignVersion)} 
			else
				return false
			end
		end,
	}
}
	