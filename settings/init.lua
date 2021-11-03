local base = select(1, ...).."."
local out = {}

local function load(name,...)
	out[name] = require(base..name)
	for _,alias in ipairs({...}) do
		out[alias] = out[name]
	end
end

load("dimensions", "dim")
load("bindings", "keys")
load("misc")
load("theme")

return out
