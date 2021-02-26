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
					local node = path.head
					while node do
						if node.x < level.left or node.x > level.right or node.y < level.top or node.y > level.bottom then
							return node.x, node.y
						end
						node = node.next
					end
				end
				return false
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
