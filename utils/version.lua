local V = {}

V.current = love.filesystem.read("version.txt") or "DEV"

V.previous = Storage.version
Storage.version = V.current
Storage.save()

function V.parseVersion(str)
	local out = {}
	local i=1
	for part in str:gmatch("([^%.])") do
		out[i] = tonumber(part)
		i = i + 1
	end
	return out
end

---@return -1|0|1 sign -1 if a < b, 0 if a==b, 1 if a > b
function V.compare(a,b)
	for i,v in ipairs(b) do
		if (a[i] or 0) > v then
			return 1
		elseif (a[i] or 0) < v then
			return -1
		end
	end
	return 0
end

function V.compareStrings(a,b)
	return V.compare(V.parseVersion(a),V.parseVersion(b))
end

function V.isLessThan(a,b, orEquals)
	if orEquals==nil then orEquals = false end
	local c = V.compareStrings(a,b)
	return c==-1 or (orEquals and c==0)
end

function V.isHigherThan(a,b, orEquals)
	if orEquals==nil then orEquals = false end
	local c = V.compareStrings(a,b)
	return c==1 or (orEquals and c==0)
end

return V