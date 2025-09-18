local u = {}

local function offsetObject(obj,dx,dy,done)
	done[obj] = true
	local x,y = obj.x+dx, obj.y+dy
	local taken = obj.world[obj.layer][x][y]
	if taken then
		offsetObject(taken,dx,dy,done)
	end
	obj.world:moveObject(obj, obj.x+dx, obj.y+dy)
end

local function offsetPathNode(pn,dx,dy,done)
	done[pn] = true
	local x,y = pn.x+dx, pn.y+dy
	local taken = pn.path.world.pathNodes[x][y]
	if taken then
		offsetPathNode(taken,dx,dy,done)
	end
	pn.path.world:movePathNode(pn, pn.x+dx, pn.y+dy)
end

function u.offsetEverything(world,dx,dy)
	if dx==0 and dy==0 then
		--prevent stack overflow due to object trying to move itself first,
		--before moving, getting stuck in an infinite loop
		return
	end
	local done = {}
	for obj in world.objects:iterate() do
		if not done[obj] then
			offsetObject(obj,dx,dy,done)
		end
	end
	for path in world.paths:iterate() do
		local node = path.head
		while node do
			if not done[node] then
				offsetPathNode(node,dx,dy,done)
			end
			node = node.next
		end
	end
end

return u
