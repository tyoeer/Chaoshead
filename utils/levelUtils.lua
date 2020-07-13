local u = {}

function u.load(path)
	f = require("levelhead.lhs"):new(path)
	f:readAll()
	return f:parseAll()
end

function u.save(level,path)
	f = require("levelhead.lhs"):new(path)
	f:serializeAll(level)
	f:writeAll()
end

return u
