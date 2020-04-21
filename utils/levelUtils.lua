local u = {}

function u.reload()
	levelFile:reload()
	levelFile:readAll()
	level = levelFile:parseAll()
end

function u.save()
	levelFile:serializeAll(level)
	levelFile:writeAll()
end

return u
