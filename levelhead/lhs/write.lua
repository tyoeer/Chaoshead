local LHS = {}

--misc

function LHS:write(data)
	if type(data)=="number" then
		data = math.numberToBytesLE(data)
	end
	self.saveHandle:write(data)
end

function LHS:write2(data)
	data = math.numberToBytesLE(data)
	if data:len()==1 then
		self.saveHandle:write(data)
		self.saveHandle:write(string.char(0x00))
	elseif data:len()>2 then
		error(love.data.encode("string","hex",data))
	else
		self.saveHandle:write(data)
	end
end

local function deHex(d)
	return love.data.decode("string","hex",d)
end

--writing

function LHS:writeHeaders()
	local h = self.rawHeaders
	--Prefix (unknown) taken from my own code test level
	self:write(deHex("F82AD32C010000"))
	--TitleDivider (unknown) is always this value
	self:write(0x08)
	
	--stuff we know, the values in between appear to be fixed,
	-- but still need to be properly investigated (and added to the lhs doc)
	self:write(0x00)
	self:write(h.music)
	self:write(0x01)
	self:write(h.mode)
	self:write(0x02)
	self:write(h.minPlayers)
	self:write(0x03)
	self:write(h.sharePowerups and 0x01 or 0x00)
	self:write(0x04)
	self:write(h.weather and 0x01 or 0x00)
	self:write(0x05)
	self:write(h.language)
	self:write(0x06)
	self:write(h.mpRespawnStyle)
	self:write(0x07)
	self:write(h.horCameraBoundary and 0x01 or 0x00)
	
	--title
	for i=1,8,1 do
		self:write(h.title[i])
		if i ~= 8 then
			self:write("|")
		end
	end
	self:write(0x00)
	
	--zone and size
	self:write(h.zone)
	self:write(h.width)
	self:write(h.height)
	
	--DividerConstant (unknown), it's always this
	self:write(deHex("0000803F"))
end

function LHS:writeSingleForeground()
	local c = self.rawContentEntries.singleForeground
	self:write(0x0D)
	self:write2(c.nEntries)
	for _,v in ipairs(c.entries) do
		self:write2(v.id)
		self:write2(v.amount)
		for _,o in ipairs(v.objects) do
			self:write(o.x)
			self:write(o.y)
		end
	end
end

function LHS:writeHash()
	self:write(0x61)
	self:write(string.rep("A",32))
	self:write(0)
end


function LHS:writeAll()
	local file, err = io.open(self.path,"wb")
	if err then error(err) end
	self.saveHandle = file
	
	self:writeHeaders()
	self:writeSingleForeground()
	--add empty categories to be reverse engineered
	do
		local w = function(d)
			self:write(d)
			self:write2(0x00)
		end
		w(0x13)
		w(0x0B)
		w(0x63)
		w(0x43)
		w(0x3A)
		w(0x15)
		w(0x19)
		w(0x1B)
		w(0x0D)
	end
	self:writeHash()
	
	self.saveHandle:close()
	self.saveHandle = nil
end

return LHS
