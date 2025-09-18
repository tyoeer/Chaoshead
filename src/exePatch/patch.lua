local P = Class("ExePatch")

local REGION_OFFSET = 4096

function P:initialize(path)
	self.blocks = {}
	self.totalCount = 0
	
	-- Load and check patch
	local patch, err = love.filesystem.read(path)
	if not patch then
		error("Could not read patch file:\n"..tostring(err))
	end
	local target = patch:match("^%>(%S+)")
	if target~="levelhead.exe" then
		error("Patch file is not targeting levelhead, but: "..tostring(target).."\n"..patch)
	end
	
	local block = self:newBlock()
	local lastLine
	
	for hexRva, hexFrom, hexTo in patch:gmatch("\n(%S+):(%S+)%->(%S+)") do
		if not hexRva or not hexFrom or not hexTo then
			error(string.format("Error parsing patch: %s: %s -> %s",hexRva, hexFrom, hexTo))
		end
		self.totalCount = self.totalCount + 1
		local line = {
			rva = tonumber(hexRva, 16),
			from = tonumber(hexFrom, 16),
			to = tonumber(hexTo, 16),
		}
		if lastLine and line.rva < lastLine.rva then
			error("Expected rva increase at "..hexRva.." #"..self.totalCount)
		end
		if lastLine and line.rva-lastLine.rva > 10 then
			block = self:newBlock()
		end
		
		table.insert(block.lines, line)
		lastLine = line
	end
	
	for _,block in ipairs(self.blocks) do
		block.first = block.lines[1].rva
		block.regionStart = block.first - REGION_OFFSET
		block.last = block.lines[#block.lines-1].rva
		block.regionEnd = block.last + REGION_OFFSET
	end
end

function P:newBlock()
	local block = {
		lines = {}
	}
	table.insert(self.blocks, block)
	return block
end

return P