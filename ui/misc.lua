local UI = Class(require("ui.structure.padding"))

function UI:initialize()
	local list = require("ui.structure.list"):new()
	
	list:addButtonEntry("Open scripts folder",function()
		local url = "file://"..love.filesystem.getSaveDirectory().."/"..require("script").folder
		love.system.openURL(url)
	end)
	
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
	list:addButtonEntry("UI testing time, or WHY DOES getMinimumHeight() NOT WORK PROPERLY?!?!?!?!",function()
		local buttons = require("ui.structure.list"):new()
		buttons:addTextEntry(" ",0)
		buttons:addTextEntry(" ",0)
		buttons:addTextEntry(" ",0)
		for i=1,100,1 do
			local button
			if i%2==0 then
				button = require("ui.list.text"):new(i,i%7)
			else
				button = require("ui.list.button"):new(i,i%9)
			end
			button = require("ui.structure.padding"):new(button,(i%5)*10)
			buttons:addUIEntry(button)
		end
		buttons = require("ui.structure.scrollbar"):new(buttons)
		ui.child.child:addChild(buttons)
	end)
	list:addButtonEntry("save_data change beeper (bring your own beep.wav in the chaoshead data folder)",function()
		local NFS = require("libs.nativefs")
		local userCodes = require("levelhead.userData").getUserCodes()
		local dataPath = require("levelhead.misc").getUserDataPath()
		local beep = love.audio.newSource("beep.wav","static")
		local lastTime = 0
		
		local B = Class(require("ui.list.text"))
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
		ui:setUIModal(beepr)
	end)
	
	
	UI.super.initialize(self,list,settings.dim.misc.miscPadding)
	self.title = "Misc."
end

return UI
