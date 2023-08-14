local NFS = require("libs.nativefs")

local m = {}

function m.getDataPath()
	local custom = Settings.misc.levelheadDataPath
	if custom and custom~="" then
		if custom:sub(-1)~="/" then
			custom = custom .. "/"
		end
		return custom
	elseif love.system.getOS()=="Linux" then
		--flatpak
		return love.filesystem.getUserDirectory()..".var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/792710/pfx/drive_c/users/steamuser/AppData/Local/PlatformerBuilder/"
	else
		return love.filesystem.getUserDirectory().."AppData/Local/PlatformerBuilder/"
	end
end

function m.getUserDataPath()
	return m.getDataPath().."UserData/"
end

local installationPaths = {
	"C:/Program Files (x86)/Steam/steamapps/common/Levelhead/",
	love.filesystem.getUserDirectory()..".var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Levelhead/", -- Linux (flatpak)
}
function m.getInstallationPath()
	local customDir = Settings.misc.levelheadInstallationPath
	if customDir and customDir~="" then
		if customDir:sub(-1)~="/" then
			customDir = customDir .. "/"
		end
		local info = NFS.getInfo(customDir.."Levelhead.exe")
		if info then
			return customDir
		end
	end
	for _,dir in ipairs(installationPaths) do
		local info = NFS.getInfo(dir.."Levelhead.exe")
		if info then
			return dir
		end
	end
	return nil
end

local function hasSpaceBetween(first,second)
	if first=="" or first==nil then
		return false
	end
	if second=="word" then
		return not (first=="¿" or first=="-")
	elseif second=="&" then
		return true
	elseif second:match("%d") then
		return not ( first:match("%.") or first=="-" or first:match("%d") )
	else
		return false
	end
end
function m.parseLevelName(parts)
	if type(parts)=="table" then
		local out = ""
		local previous
		for _,part in ipairs(parts) do
			if part:match("%_") then
				local le = part:match("iin%_(.+)")
				if le then
					part = require("levelhead.data.elements"):getName(tonumber(le))
				else
					part = part:match(".+%_.+%_(.+)")
					if not part then
						error(string.format("Error parsing level name part %q",part))
					end
					local first = part:sub(1,1)
					local notFirst = part:sub(2)
					part = first:upper()..notFirst
				end
				if hasSpaceBetween(previous,"word") then
					out = out.." "..part
				else
					out = out..part
				end
				previous = "word"
			elseif part~="" then
				if hasSpaceBetween(previous,part) then
					out = out.." "..part
				else
					out = out..part
				end
				previous = part
			end
		end
		if out=="" then out = "$Unnamed Level" end
		return out
	end
end

return m
