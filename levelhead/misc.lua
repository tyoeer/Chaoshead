local m = {}

function m.getDataPath()
	return love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/"
end
function m.getUserDataPath()
	return m.getDataPath().."UserData/"
end

--[[
it doesn't match levelhead exactly,
because levelhead has stupid rules where a digit is prepended by a space,
unless a digit, "-", ".", or "..." are before the digit
not going to bother with all the complicated rules now
]]--
function m.parseLevelName(name)
	if type(name)=="table" then
		local out = ""
		local previous
		for _,part in ipairs(name) do
			if part:match("%_") then
				local le = part:match("iin%_(.+)")
				if le then
					part = require("levelhead.data.elements"):getName(tonumber(le))
				else
					part = part:match(".+%_.+%_(.+)")
					if not part then table.print(name) end
					local first = part:sub(1,1)
					local notFirst = part:sub(2)
					part = first:upper()..notFirst
				end
				if previous then
					out = out.." "..part
				else
					out = part
				end
				previous = "word"
			else
				if previous=="symbol" then
					out = out..part
				else
					out = out.." "..part
				end
				previous = "symbol"
			end
		end
		return out
	end
end

return m
