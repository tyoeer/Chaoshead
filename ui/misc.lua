local UI = Class("MiscTabUI",require("ui.tools.details"))

function UI:initialize()
	UI.super.initialize(self)
	self.title = "Misc."
end

function UI:onReload(list)
	
	
	-- INFORMATION
	
	
	list:addButtonEntry("Open user data folder",function()
		local url = "file://"..love.filesystem.getSaveDirectory()
		love.system.openURL(url)
	end)
	
	
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
				local time = NFS.getInfo(path).modtime
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
		local beepr = B:new("Will beep when a save_data gets modified. Alt+F4 to stop.",0)
		ui:setModal(beepr)
	end)
	
end

return UI
