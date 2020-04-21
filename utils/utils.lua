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

function math.negativeRound(x)
	return math.sign(x)*math.round(math.abs(x))
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function math.lerp(n,m,t)
  return n+t*(m-n)
end


function math.isPointInRectangle(x,y,xmin,ymin,xmax,ymax)
	return x>=xmin and x<xmax and y>=ymin and y<ymax
end
--https://stackoverflow.com/a/13390495
function math.rectanglesIntersect(x1,y1,w1,h1,x2,y2,w2,h2)
	return not (x1+w1<x2 or x2+w2<x1 or y1+h1<y2 or y2+h2<y1)
end


function math.splitSeconds(seconds)
	local t={}
	t.minutes=math.floor(seconds/60)
	t.seconds=math.floor(seconds-t.minutes*60)
	t.milliseconds=math.round(math.fmod(seconds,1)*1000)
	return t
end

function math.romanNumber(number)
	--init
	local characters = {"I","V","X","L","C","D","M",  "Q","Q"}--the Q's are to prevent an overflow
	local digitTemplates = {"","1","11","111","12","2","21","211","2111","13"}
	local size = tostring(number):len()
	local out = ""
	--loop the digits
	for digit in tostring(number):gmatch(".") do
		print(digit,number,tonumber(digit))
		local newDigit = digitTemplates[tonumber(digit)+1]
		--fill the template with the right characters
		newDigit = newDigit:gsub("1",characters[size*2-1])
		newDigit = newDigit:gsub("2",characters[size*2])
		newDigit = newDigit:gsub("3",characters[size*2+1])
		out = out..newDigit
		size = size - 1
	end
	return out
end

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



function table.getLength(inputTable)
  local count = 0
  for _,_ in pairs(inputTable) do count = count + 1 end
  return count
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

function table.serialize(inputTable)
	local out="{"
	for k,v in pairs(inputTable) do
        --add the key
		if type(k)=="string" then
			if k:find("[^a-zA-Z0-9]") then
                out = out.."["..string.format("%q",k).."]"
            else
                out = out..k
            end
		elseif type(k)=="table" then
            out = out.."["..table.serialize(k).."]"
        else
            out = out.."["..tostring(k).."]"
        end
		out = out.."="
        --add the value
		if type(v)=="string" then
			out=out..string.format("%q",v)
		elseif type(v)=="table" then
			out=out..table.serialize(v)
		else
			out=out..tostring(v)
		end
		out=out..","
	end
	
	return out.."}"
end

function table.prepareForVariant(inputTable)
	for k,v in pairs(inputTable) do
		if type(v)=="function" then
			local newString=string.dump(v)
			inputTable[k]={isAFunction=true,functionString=newString}
		elseif type(v)=="table" then
			inputTable[k]=table.prepareForVariant(v)
		end
	end
	
	return inputTable
end

function table.loadFromVariant(inputTable)
	for k,v in pairs(inputTable) do
		if type(v)=="table" and v.isAFunction then
			inputTable[k]=loadstring(v.functionString)
		end
	end
	
	return inputTable
end

--copied this function from somewhere
function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--from https://www.stackoverflow.com/a/41350070
local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end


--from http://lua-users.org/wiki/StringTrim trim3
function string.trim(s)
  return s:gsub("^%s+", ""):gsub("%s+$", "")
end
--from https://stackoverflow.com/questions/19326368/iterate-over-lines-including-blank-lines
function string.lines(s)
        if s:sub(-1)~="\n" then s=s.."\n" end
        return s:gmatch("(.-)\n")
end
--from http://www.lua.org/pil/20.4.html
function string.depatternize(s)
	return string.gsub(s,"(%W)","%%%1")
end

function string.extractNumber(s)
	s:gsub("%D","")
	return tonumber(s)
end
