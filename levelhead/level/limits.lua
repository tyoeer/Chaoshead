local P = require("levelhead.data.properties")

return {
	--[[
		message: which message to display if check return true
		check: returns something true if the level breaks this limit, false otherwise
		the message gets string.format()ted with whatever check returned
	]]--
	file = {
		--level size
		{
			message = "Width is above 255!",
			check = function(level)
				return level:getWidth() > 255
			end,
		},
		{
			message = "Height is above 255!",
			check = function(level)
				return level:getHeight() > 255
			end,
		},
		{
			message = "Width is below 0!",
			check = function(level)
				return level:getWidth() < 0
			end,
		},
		{
			message = "Height is below 0!",
			check = function(level)
				return level:getHeight() < 0
			end,
		},
		--outside bounds
		{
			message = "The %s at (%i,%i) is outside bounds!",
			check = function(level)
				for obj in level.objects:iterate() do
					if obj.x < level.left or obj.x > level.right or obj.y < level.top or obj.y > level.bottom then
						return obj:getName(), obj.x, obj.y
					end
				end
				return false
			end,
		},
		{
			message = "The path node at (%i,%i) is outside bounds!",
			check = function(level)
				for path in level.paths:iterate() do
					for node in path:iterateNodes() do
						if node.x < level.left or node.x > level.right or node.y < level.top or node.y > level.bottom then
							return node.x, node.y
						end
					end
				end
				return false
			end,
		},
		--properties
		{
			message = "The property %q in the %s at (%i,%i) has an unknown save format!",
			check = function(level)
				--objects
				for obj in level.objects:iterate() do
					for prop in obj:iterateProperties() do
						local sf = P:getSaveFormat(prop)
						if sf=="$UnknownSaveFormat" then
							local name = P:getName(prop)
							if name=="$UnknownName" then name = prop end
							return name, "object", obj.x, obj.y
						end
					end
				end
				--paths
				for path in level.paths:iterate() do
					for prop in path:iterateProperties() do
						local sf = P:getSaveFormat(prop)
						if sf=="$UnknownSaveFormat" then
							local name = P:getName(prop)
							if name=="$UnknownName" then name = prop end
							return name, "path", path.head.x, path.head.y
						end
					end
				end
			end,
		},
		{
			message = "The property %q in the %s at (%i,%i) is outside its saveable range (%i-%i) with the value %i!",
			check = function(level)
				local function checkProp(prop,val)
					local sf = P:getSaveFormat(prop)
					--unknown save formats have already been checked for
					local min,max
					if sf=="A" then
						min = 0
						max = 255
					elseif sf=="B" then
						min = -32768
						max = 32767
					elseif sf=="C" then
						min = -math.huge
						max = math.huge
					elseif sf=="D" then
						min = -128
						max = 127
					else
						error(string.format("This place should not be reachable (%q)",sf))
					end
					if val < min or val > max then
						return val,min,max
					else
						return false
					end
				end
				
				--objects
				for obj in level.objects:iterate() do
					for prop in obj:iterateProperties() do
						local val,min,max = checkProp(prop,obj:getPropertyRaw(prop))
						if val then
							local name = P:getName(prop)
							if name=="$UnknownName" then name = prop end
							return name, "object", obj.x,obj.y, min,max, val
						end
					end
				end
				
				--paths
				for path in level.paths:iterate() do
					for prop in path:iterateProperties() do
						local val,min,max = checkProp(prop,path:getPropertyRaw(prop))
						if val then
							local name = P:getName(prop)
							if name=="$UnknownName" then name = prop end
							return name, "path", path.head.x,path.head.y, min,max, val
						end
					end
				end
			end,
		},
	},
	editor = {
		-- level size
		{
			message = "Width is below 30!",
			check = function(level)
				return level:getWidth() < 30
			end,
		},
		{
			message = "Height is below 30!",
			check = function(level)
				return level:getHeight() < 30
			end,
		},
		{
			message = "Area is above 10 000! (%ix%i=%i)",
			check = function(level)
				local w = level:getWidth()
				local h = level:getHeight()
				local area = w*h
				if area > 10000 then
					return w,h,area
				else
					return false
				end
			end,
		},
	},
}
