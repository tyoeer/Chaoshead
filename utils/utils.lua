function math.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function math.round(x)
  return math.floor(x+0.5)
end

function math.roundPrecision(val, precision)
	--return math.floor( (val * 1/precision) + 0.5) / (1/precision)
	--simplified:
	return math.floor((val/precision)+0.5)*precision
end

function math.isPointInRectangle(x,y,xmin,ymin,xmax,ymax)
	return x>=xmin and x<xmax and y>=ymin and y<ymax
end
--[[
--big endian
function math.numberToBytes(myNumber)
	local output={}
	local i=0
	while i<200 do
		i=i+1
		output[i]=math.fmod(myNumber,256)
		--myNumber=math.fmod(myNumber,256)
		myNumber=math.floor(myNumber/256)
		if myNumber < 256 then
			if myNumber~=0 then
				output[i+1]=myNumber
			end
			break
		end
	end
	local newOutput={}
	
	for i,v in reversedipairs(output) do
		table.insert(newOutput,v)
	end
	
	
	return string.char(unpack(newOutput))
end

function math.bytesToNumber(bytes)
	local i=0
	local result=0
	for char in bytes:reverse():gmatch(".") do
		result=result+( char:byte()*(256^i) )
		i=i+1
	end
	return result
end
]]--
--little endian
function math.numberToBytesLE(myNumber)
	local output={}
	local i=0
	while i<200 do
		i=i+1
		output[i]=math.fmod(myNumber,256)
		--myNumber=math.fmod(myNumber,256)
		myNumber=math.floor(myNumber/256)
		if myNumber < 256 then
			if myNumber~=0 then
				output[i+1]=myNumber
			end
			break
		end
	end
	
	local newOutput={}
	for i,v in ipairs(output) do
		table.insert(newOutput,v)
	end
	
	return string.char(unpack(newOutput))
end

function math.bytesToNumberLE(bytes)
	local i=0
	local result=0
	for char in bytes:gmatch(".") do
		result=result+( char:byte()*(256^i) )
		i=i+1
	end
	return result
end



local function printTable(inputTable,tabs)
	if tabs>7 then print(string.rep("  ",tabs).."...") return end
	for k,v in pairs(inputTable) do
		if type(v)=="table" then
			print(string.rep("  ",tabs)..k,"{")
			printTable(v,tabs+1)
			print(string.rep("  ",tabs).."}")
		else
			print(string.rep("  ",tabs)..k,v)
		end
	end
end
function table.print(inputTable)
	printTable(inputTable,0)
end


--from http://lua-users.org/wiki/StringTrim trim3
function string.trim(s)
  return s:gsub("^%s+", ""):gsub("%s+$", "")
end

--from http://www.lua.org/pil/20.4.html
function string.depatternize(s)
	return string.gsub(s,"(%W)","%%%1")
end
