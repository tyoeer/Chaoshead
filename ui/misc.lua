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
		local i =love.filesystem.getInfo("campaign.bin")
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
	
	UI.super.initialize(self,list,settings.dim.misc.padding)
	self.title = "Misc."
end

return UI
