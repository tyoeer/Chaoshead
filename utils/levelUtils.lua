local u = {}

function u.reload()
	levelFile:readAll()
	level = levelFile:parseAll()
end

return u
