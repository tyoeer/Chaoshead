local m = {}

function m.getDataPath()
	return love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/"
end

return m
