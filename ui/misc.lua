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
	list:addButtonEntry("Test LH folder detection",function()
		local M = require("levelhead.misc")
		print(M.getDataPath())
		print(M.getUserDataPath())
		local UD = require("levelhead.userData")
		print("----------")
		table.print(UD.getUserCodes())
		print("----------")
		local listCmd = "dir"
		local cdCmd = "cd \""..require("levelhead.misc").getUserDataPath().."\""
		local sd = love.filesystem.getSaveDirectory().."/"
		local out1 = " 1>\""..sd.."out1.txt\" 2>\""..sd.."err1.txt\" "
		local out2 = " 1>\""..sd.."out2.txt\" 2>\""..sd.."err2.txt\" "
		local out3 = " 1>\""..sd.."out3.txt\" 2>\""..sd.."err3.txt\" "
		local cmd = cdCmd..out1.." && ".."cd"..out2.." && "..listCmd..out3
		print(cmd)
		
		print("----------")
		local cli = io.popen(cmd,"r")
		local list = cli:read("*all")
		cli:close()
		print(list)
		print("----------")
	end)
	
	UI.super.initialize(self,list,settings.dim.misc.padding)
	self.title = "Misc."
end

return UI
