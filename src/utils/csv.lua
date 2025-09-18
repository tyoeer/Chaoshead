local csv = {}

local function preprocess(item)
	item = item:trim()
	item = tonumber(item) or item
	if item=="" then
		item = nil
	end
	return item
end

function csv.parseString(text,seperator)
	local SEP = seperator or ","
	local END = "\n"
	
	local out
	local headers = {}
	local column = 1
	local current = ""
	
	for i=1,text:len(),1 do
		local char = text:sub(i,i)
		if char==SEP then
			if out and current then
				current = preprocess(current)
				out[#out][headers[column]] = current
			else
				headers[column] = current
			end
			current = ""
			column = column + 1
		elseif char==END then
			if out then
				current = preprocess(current)
				out[#out][headers[column]] = current
			else
				-- a CR char might hang around in the current due to the END char being only one character of windows 2-chars newline
				current = current:trim()
				headers[column] = current
				out = {}
			end
			out[#out + 1] = {}
			column = 1
			current = ""
		else
			--print(i,char)
			current = current .. char
		end
	end
	-- if the file doesn't end with a newline, append what's left
	if current then
		current = preprocess(current)
		out[#out][headers[column]] = current
	end
	return out, headers
end

return csv
