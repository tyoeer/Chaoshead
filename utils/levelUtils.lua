local u = {}

function u.reload()
	levelFile:reload()
	levelFile:readAll()
	level = levelFile:parseAll()
end

function u.save()
	levelFile:writeAll()
end

return u
