local UI = Class("MiscTabUI",require("ui.tools.details"))

function UI:initialize()
	UI.super.initialize(self)
	self.title = "Misc."
end

function UI:onReload(list)
	
	
	-- BASIC INFORMATION
	
	list:addTextEntry("Chaoshead version "..require("utils.version").current)
	list:addTextEntry(string.format("LÖVE version %d.%d.%d %s",love.getVersion()))
	
	-- DO STUFF
	
	list:addButtonEntry("Toggle fullscreen",function()
		MainUI:toggleFullscreen()
	end)
	
	list:addButtonEntry("Exit Chaoshead",function()
		love.event.quit()
	end)
	list:addButtonEntry("Show keybinds",function()
		local function parseName(name)
			return name:gsub("[A-Z]",function(s)
				return " "..s
			end):gsub("^.",string.upper)
		end
		
		local function parseBind(bind)
			if type(bind)=="string" then
				local m = bind:match("mouse: ?(.)")
				if m then
					return m:upper().."mouse"
				end
				local k = bind:match("key: ?(.+)")
				if k then
					return parseName(k)
				end
				return parseName(bind)
			end
			if bind.type then
				if bind.type=="not" then
					return "NOT "..bind.trigger
				else
					local out = ""
					if bind.type=="nor" or bind.type=="nand" then
						out = "NOT ("
					end
					
					local sep = ";"
					if bind.type:match("and") then
						sep = " AND "
					elseif bind.type:match("or") then
						sep = " OR "
					end
					
					local first = true
					for _,trig in ipairs(bind.triggers) do
						if not first then
							out = out..sep
						end
						if trig.type and (trig.type=="and" or trig.type=="or") then
							out = out.."("..parseBind(trig)..")"
						else
							out = out..parseBind(trig)
						end
						first = false
					end
					
					if bind.type=="nor" or bind.type=="nand" then
						out = out..")"
					end
					return out
				end
			else
				return parseBind(bind.trigger)
			end
		end

		local l = require("ui.layout.list"):new(Settings.theme.details.listStyle)
		for category, binds in pairs(Settings.bindings) do
			l:addTextEntry(parseName(category), 0)
			for name, val in pairs(binds) do
				l:addTextEntry(parseName(name)..": "..parseBind(val), 1)
			end
		end
		MainUI:displayMessage(l)
	end)
	
	-- DIVIDER
	list:addTextEntry("")
	
	-- OPEN FOLDERS
	
	list:addButtonEntry("Open Chaoshead data folder",function()
		local url = "file://"..love.filesystem.getSaveDirectory()
		love.system.openURL(url)
	end)
	
	list:addButtonEntry("Open Levelhead data folder",function()
		local url = "file://"..require("levelhead.misc").getDataPath()
		love.system.openURL(url)
	end)
	list:addButtonEntry("Open Levelhead installation folder",function()
		local path = require("levelhead.misc").getInstallationPath()
		if not path then
			MainUI:displayMessage("Could not find Levelhead installation directory\n"
				.."If you are using the non-Steam version, please get in touch so support can be added.")
			return
		end
		local url = "file://"..path
		love.system.openURL(url)
	end)
	
	-- DIVIDER
	list:addTextEntry("")
	
	list:addButtonEntry("Check for updates", function()
		local c = require("ui.startupChecks").checkForUpdate(true)
		if c then
			MainUI:displayMessage("Your Chaoshead is up to date.")
		end
	end)
	list:addButtonEntry("Patch Levelhead executable to get rid of level caching (also disables caching for some other files) (experimental)",function()
		-- The patch file gives addresses, which appear at a weird place in the file
		-- This offset has been found by comparing the address and file offset as given by x32dbg
		local addressOffset = -3072
		
		-- Load and check patch
		local patch, err = love.filesystem.read("exeMods/noCache.1337")
		if not patch then
			MainUI:displayMessage("Could not read patch file: "..tostring(err))
			return
		end
		local target = patch:match("^%>(%S+)")
		if target~="levelhead.exe" then
			MainUI:displayMessage("ERROR: Patch file is not targeting levelhead, but: "..tostring(target).."\n"..patch)
			return
		end
		
		-- Open executable
		local dir = require("levelhead.misc").getInstallationPath()
		if not dir then
			MainUI:displayMessage("Could not find Levelhead installation directory\n"
				.."If you are using the non-Steam version, please get in touch so support can be added.")
			return
		end
		--Can't use nativefs because it doesn't let us open the file in a way to edit in it's middle
		local file, err = io.open(dir.."Levelhead.exe","r+b")
		if not file then
			MainUI:displayMessage("Could not open executable:\n"..tostring(err))
			return
		end
		
		-- Verify the executable looks as expected
		local count=0
		for hexOffset, hexFrom, hexTo in patch:gmatch("\n(%S+):(%S+)%->(%S+)") do
			-- Verify line parsed correctly
			if not hexOffset or not hexFrom or not hexTo then
				MainUI:displayMessage(string.format("Error parsing patch: %s: %s -> %s",hexOffset, hexFrom, hexTo))
				return
			end
			count = count+1
			
			-- Parse offset
			local offset = tonumber(hexOffset,16)
			if not offset then
				MainUI:displayMessage(string.format("Error parsing offset %s", hexOffset))
				return
			end
			offset = offset + addressOffset
			
			-- Read byte
			file:seek("set", offset)
			local actual = file:read(1)
			if not actual then
				MainUI:displayMessage(
					string.format("Could not read at offset %s (%X/%i)",
					hexOffset, offset, offset)
				)
				return
			end
			
			--Verify it's the correc one
			if string.byte(actual) ~= tonumber(hexFrom, 16) then
				MainUI:displayMessage(
					string.format(
						"Expected %s at offset %s (%X/%i) (%X/%i), found %s (%s)\n",
						hexFrom, hexOffset,   offset, offset,   file:seek(), file:seek(), 
						love.data.encode("string","hex",actual), love.data.encode("string","hex",file:read(5))
					)..(string.byte(actual)==tonumber(hexTo,16) and "That's the value we want it to be. Did you already patch it?" or "")
				)
				return
			end
		end
		
		-- Verify we parsed the patch file correctly
		if count~=37 then
			MainUI:displayMessage("Expected 5 patches, found "..count)
			return
		end
		
		Storage.patched = {
			at = os.time(),
			succesful = false
		}
		Storage:save()
		
		for hexOffset, hexFrom, hexTo in patch:gmatch("\n(%S+):(%S+)%->(%S+)") do
			-- Verify line parsed correctly
			if not hexOffset or not hexFrom or not hexTo then
				MainUI:displayMessage(string.format("Error parsing patch: %s: %s -> %s",hexOffset, hexFrom, hexTo))
				return
			end
			
			-- Parse offset
			local offset = tonumber(hexOffset,16)
			if not offset then
				MainUI:displayMessage(string.format("Error parsing offset %s", hexOffset))
				return
			end
			offset = offset + addressOffset
			
			-- Write byte
			file:seek("set", offset)
			local ok, err = file:write(love.data.decode("string","hex",hexTo))
			if not ok then
				MainUI:displayMessage(string.format("Error writing %s at offset %s (%X/%i): %s", hexTo, hexOffset, offset, offset, err))
				return
			end
		end
		
		local ok, err = file:close()
		if not ok then
			MainUI:displayMessage("Error closing file:\n"..tostring(err))
			return
		end
		
		Storage.patched.succesful = true
		Storage:save()
		MainUI:displayMessage("Looks like patching was succesful.\nPlease report any Levelhead problems/crashes, this is experimental.")
	end)
	
	-- DIVIDER
	list:addTextEntry("")
	
	-- CAMPAIGN
	
	list:addButtonEntry("Decompress campaign (move the hardfile to the chaoshead data folder first)",function()
		local i =love.filesystem.getInfo("campaign_hardfile")
		if i then
			local c = love.filesystem.read("campaign_hardfile")
			print("Beginning decompression...")
			local d = love.data.decompress("data","zlib",c)
			print("Decompressed! Writing to disk...")
			love.filesystem.write("campaign.bin",d)
			print("Done!")
		else
			print("No campaign_hardfile found!")
		end
	end)
	
	list:addButtonEntry("Compress campaign (from campaign.bin in the chaoshead data folder)",function()
		local i = love.filesystem.getInfo("campaign.bin")
		if i then
			local c = love.filesystem.read("campaign.bin")
			print("Beginning compression...")
			local d = love.data.compress("data","zlib",c,9)
			print("Compressed! Writing to disk...")
			love.filesystem.write("campaign_hardfile",d)
			print("Done!")
		else
			print("No campaign.bin found!")
		end
	end)
	
	list:addButtonEntry("Rehash campaign.bin",function()
		local i = love.filesystem.getInfo("campaign.bin")
		if i then
			local f = love.filesystem.newFile("campaign.bin")
			f:open("r")
			local s = f:getSize()
			local h = require("levelhead.lhs").hash(f:read(s-33))
			f:close()
			f:open("a")
			f:seek(s-33)
			f:write(h)
			f:close()
			print("Overwritten",h)
		else
			print("No campaign.bin found!")
		end
	end)
	
	
	-- ALERTS/BEEPERS
	
	
	list:addButtonEntry("save_data change beeper (bring your own beep.wav in the chaoshead data folder)",function()
		local NFS = require("libs.nativefs")
		local userCodes = require("levelhead.userData").getUserCodes()
		local dataPath = require("levelhead.misc").getUserDataPath()
		local beep = love.audio.newSource("beep.wav","static")
		local lastTime = 0
		
		local B = Class(require("ui.widgets.text"))
		function B:update()
			for _,v in ipairs(userCodes) do
				local path = dataPath..v.."/save_data"
				local info = NFS.getInfo(path)
				if info then
					local time = info.modtime
					if time > lastTime then
						lastTime = time
						beep:stop()
						beep:play()
					end
					local f = NFS.newFile(path)
					local success,error = f:open("a")
					if success then
						f:close()
					else
						self.text = self.text .. "\n"..error
						if not beep:isPlaying() then
							beep:play()
						end
					end
				end
			end
		end
		local beepr = B:new("Will beep when a save_data gets modified. Alt+F4 to stop.",0,Settings.theme.modal.listStyle.textStyle)
		MainUI:setModal(beepr)
	end)
	
end

return UI
