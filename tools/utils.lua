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
	local taken = pn.world.pathNodes[x][y]
	if taken then
		offsetOPathNode(taken,dx,dy,done)
	end
	pn.world:movePathNode(pn, pn.x+dx, pn.y+dy)
end

function u.offsetEverything(world,dx,dy)
	local done = {}
	for obj in world.objects:iterate() do
		offsetObject(obj,dx,dy,done)
	end
	for path in world.paths:iterate() do
		local node = path.head
		while node do
			offsetpathNode(node,dx,dy,done)
			node = node.next
		end
	end
end

return u
