local C

local function extend(v)
	return type(v)=="table" and C(v) or C{v,v,v}
end
local cMeta = {
	__call = function(self, op, oth)
		return {
			op(self[1], oth[1]),
			op(self[2], oth[2]),
			op(self[3], oth[3]),
			op(self[4] or 1, oth[4] or 1),
		}
	end,
	__mul = function(lhs, rhs)
		return extend(lhs)(function(a,b)
			return math.min(math.max(a*b,0),1)
		end, extend(rhs))
	end
}

---@class Color
---@operator mul(Color): Color
C = function(r,g,b,a)
	if type(r)~="table" then
		r = {r,g,b,a}
	end
	if r[4]==nil then r[4]=1 end
	return setmetatable(r,cMeta)
end

-- local accent = C{1,1,1}
-- local accent = C{0.95, 1.2, 0.95} -- green
-- local accent = C{0.95, 1, 1.2} -- blue
-- local accent = C{1.2, 1.2, 0.95} -- gold
local accent = C{1.1, 0.85, 1.1} -- fuchsia

local function accentuator(accent)
	return function(val)
		if val[1] and val[2] and val[3] then
			--this is a color
			if
				math.abs(val[1]-val[2]) < 0.025 and
				math.abs(val[2]-val[3]) < 0.025 and
				math.abs(val[1]-val[3]) < 0.025 and
				val[1]~=1
			then
				return accent * val
			end
		else
			return val
		end
	end
end

local function replaceInPlace(old, new, conv, exceptions)
	exceptions = exceptions or {}
	local replacedKeys = {}
	for key,value in pairs(new) do
		if not exceptions[key] then
			if type(value)=="table" and type(old[key])=="table" then
				replaceInPlace(old[key], conv and conv(value) or value, conv, exceptions)
			else
				old[key] = value
			end
		end
		replacedKeys[key] = true
	end
	
	local toDelete = {}
	for key,_ in pairs(old) do
		if not replacedKeys[key] then
			table.insert(toDelete, key)
		end
	end
	
	for _,key in ipairs(toDelete) do
		old[key] = nil
	end
end


return {
	setAccentColor = function(color)
		if type(color)=="string" then
			if color=="classic" then
				replaceInPlace(Settings.theme, require("utils.classicTheme"))
			elseif color=="default" then
				replaceInPlace(Settings.theme, Settings.defaults.theme)
			end
		else
			color = C(color)
			replaceInPlace(Settings.theme, Settings.defaults.theme, accentuator(color), {rulerStyle = true})
		end
		Settings:save("theme")
	end,
	presetColors = {
		{"Default", "default"},
		{"Classic", "classic"},
		{"Dark Blue", C{0.95, 1, 1.2}},
		{"Dark Gold", C{1.2, 1.2, 0.95}},
		{"Dark Fuchsia", C{1.1, 0.85, 1.1}},
		{"Dark Green", C{0.95, 1.2, 0.95}},
		{"Light Blue", C{1, 1, 1.5}},
		{"Light Gold", C{1.5, 1.5, 1}},
		{"Light Fuchsia", C{1.5, 1, 1.5}},
		{"Light Green", C{1, 1.5, 1}},
	},
}