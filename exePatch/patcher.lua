local Patch = require("exePatch.patch")
local List = require("ui.layout.list")


local function deHex(str)
	return tonumber(str,16)
end

local FOLDER = "exePatch/"
local PATCHES = {
	{
		title = "Disable level caching",
		description = "Disables caching for all non-Rumpus file reads",
		file = "noCache",
		size = 38,
		regions = {
			"noCacheRegion1.bin",
			"noCacheRegion2.bin"
		},
	},
}

local VERSION_FILE_OFFSET = deHex"3015AC4"
local VERSION = "1.22.4-rc.7"

-- I don't really know what RVA means, but it's what x64dbg exports :shrug:
-- This offset has been found by comparing a given RVA of the patch and it's file offset as given by x64dbg
-- The version has a different offset
local RVA_OFFSET = -3072

local function rva2offset(rva)
	return rva + RVA_OFFSET
end


local P = Class("PatcherUI", require("ui.base.proxy"))

function P:initialize()
	local list = List:new(Settings.theme.modal.listStyle)
	
	list:addTextEntry("Patches for the Levelhead executable:")
	list:addTextEntry(
		"These change code in the Levelhead executable file on disk in order to change how Levelhead works. "
		.."Because the file on disk is being patched, Levelhead should not be running while you do this, and this only has to be done once. "
	)
	list:addTextEntry(
		"A roughly 8kB region around the code to patch is verified beforehand, alongside the version the executable claims to be. "
		.."This means that problems will be detected beforehand, and if something does manage to slip the radar, "
		.."it can only do something similar to what the patch is trying to do."
	)
	list:addTextEntry("This is experimental, so please report any bugs/crashes.")
	list:addSeparator(false)
	list:addTextEntry("Available patch(es) will start to patch immediately upon clicking them:")
	for _,patchInfo in ipairs(PATCHES) do
		list:addButtonEntry(patchInfo.title, function()
			local edited, err = self:patch(patchInfo)
			if edited and not err then
				-- Success
				MainUI:displayMessage(string.format("Successfully applied patch %q", patchInfo.title), "This is experimental, please report any bugs/crashes.")
				return
			end
			if edited then
				err = "EXECUTABLE HAS BEEN EDITED, BUT PATCH FAILED MID-WAY. EXECUTABLE BEHAVIOUR IS UNDEFINED.\n"..err
			end
			MainUI:displayMessage(err)
		end)
	end
	list:addSeparator(true)
	
	P.super.initialize(self, list)
end

function P:display()
	MainUI:displayMessage(self)
end



function P:openExe()
	local dir = require("levelhead.misc").getInstallationPath()
	if not dir then
		return nil, "Could not find Levelhead installation directory\n"
			.."If you are using the non-Steam version, please get in touch so support can be added."
	end
	--Can't use nativefs because it doesn't let us open the file in a way to edit in it's middle
	local file, err = io.open(dir.."Levelhead.exe","r+b")
	if not file then
		err = "Could not open executable:\n"..tostring(err)
		if err:lower():find("permission denied") then
			err = err.."\nDid you make sure to close Levelhead before trying to patch it?"
		end
		return nil, err
	end
	
	return file, nil
end

---@param exe file*
function P:stringAt(exe, str, offset)
	exe:seek("set", offset)
	local found = exe:read(string.len(str))
	if not found then
		return false, "Reached end of file while trying to read"
	end
	if found~=str then
		if found:match("^[a-zA-Z0-9\\/._-]+$") then
			return false, string.format("Strings don't match: %q~=%q", found, str)
		else
			return false, string.format(
				"Strings don't match: 0x%s~=0x%s",
				love.data.encode("string", "hex", found):upper(),
				love.data.encode("string", "hex", str):upper()
			)
		end
	end
	local null = exe:read(1)
	if null~="\0" then
		return false, string.format("Expected \\0 string delimiter, found 0x%X/%d/%q", string.byte(null), string.byte(null), null)
	end
	return true
end

function P:verifyVersion(exe)
	if not exe then
		local file, err = self:openExe()
		if err then return false, "Failed verifying version:\n"..err end
		exe = file
	end
	local verified, err = self:stringAt(exe, VERSION, VERSION_FILE_OFFSET)
	if err then return false, "Failed verifying version:\n"..err end
	return verified
end

function P:readBlockRegion(exe, block)
	exe:seek("set", rva2offset(block.regionStart))
	local dat = exe:read(block.regionEnd - block.regionStart)
	if not dat then
		return nil, string.format("Failed reading region around block of 0x%X", block.lines[1].rva)
	end
	return dat
end

function P:loadPatch(patchInfo)
	local success, patchOrErr = pcall(function()
		return Patch:new(FOLDER..patchInfo.file..".1337")
	end)
	if not success then
		return nil, string.format("Failed loading patch file %q:\n%s", patchInfo.file, patchOrErr)
	end
	
	local patch = patchOrErr
	if patch.totalCount ~= patchInfo.size then
		return nil, string.format("Expected %i changes in patch file %q, found %i instead", patchInfo.size, patchInfo.file, patch.totalCount)
	end
	if not patchInfo.regions then
		local mainErr = string.format("Failed generating missing verification regions for patch file %q:\n",patchInfo.file)
		local exe, err = self:openExe()
		if err then
			return nil, mainErr..err
		end
		for i,block in ipairs(patch.blocks) do
			local region, err = self:readBlockRegion(exe, block)
			if not region then
				return nil, mainErr..err
			end
			local success, err = love.filesystem.write(patchInfo.file.."Region"..i..".bin", region)
			if not success then
				return nil, mainErr..err
			end
		end
		return nil, string.format("Missing verification regions for patch file %q have been generated", patchInfo.file)
	end
	if #patchInfo.regions ~= #patch.blocks then
		return nil, string.format("Expected %i blocks in patch file %q, found %i instead", #patchInfo.regions, patchInfo.file, #patch.blocks)
	end
	return patch
end

function P:patch(patchInfo)
	local mainErr = string.format("Failed applying patch %q:\n", patchInfo.title)
	
	-- Load and check patch
	local patch, err = self:loadPatch(patchInfo)
	if not patch then return false, mainErr..err end
	
	-- Open executable
	local exe, err = self:openExe()
	if not exe then return false, mainErr..err end
	
	-- Verify the executable looks as expected
	
	local success, err = self:verifyVersion(exe)
	if not success then return false, mainErr..err end
	
	for i, block in ipairs(patch.blocks) do
		--Verify individual bytes: do this before region check for detection when the exe has already been patched
		
		for _, line in ipairs(block.lines) do
			local offset = rva2offset(line.rva)
			exe:seek("set", offset)
			local char = exe:read(1)
			if not char then
				return false, mainErr..string.format("Failed reading at offset 0x%X/%i (rva 0x%X)", offset, offset, line.rva)
			end
			local byte = string.byte(char)
			if byte~=line.from then
				local err = string.format(
					"Verification failed: Expected 0x%X at offset 0x%X/%i (rva 0x%X), found 0x%X instead.",
					line.from, offset, offset, line.rva, byte
				)
				if byte==line.to then
					err = err.."\nDid you already patch the executable?"
				end
				return false, mainErr..err
			end
		end
		
		--Verify surrounding region
		
		local expected, err = love.filesystem.read(FOLDER..patchInfo.regions[i])
		if not expected then
			return false, mainErr.."Failed reading verification region "..i..":\n"..err
		end
		local region, err = self:readBlockRegion(exe, block)
		if not region then
			return false, mainErr.."Failed reading region "..i.." for verification:\n"..err
		end
		if region~=expected then
			return false, mainErr.."Verification failed: mismatch in region "..i
		end
	end
	
	Storage.patched = {
		at = os.time(),
		succesful = false
	}
	Storage:save()
	
	-- Write patch
	mainErr = mainErr.."The executable has (most likely) been modified already, please reset/redownload it before running it again to prevent unexpected problems.\n"
	for _, block in ipairs(patch.blocks) do
		for _, line in ipairs(block.lines) do
			local offset = rva2offset(line.rva)
			exe:seek("set", offset)
			local ok, err = exe:write(string.char(line.to))
			if not ok then
				return true, mainErr..string.format("Error writing 0x%X at offset 0x%X/%i (rva 0x%X):\n%s", line.to, offset, offset, line.rva, err)
			end
		end
	end
	
	local ok, err = exe:close()
	if not ok then
		return true, mainErr.."Error closing file:\n"..tostring(err)
	end
	
	Storage.patched.succesful = true
	Storage:save()
	return true, false
end

return P:new()