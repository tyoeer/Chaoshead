local csv = {}

function csv.parseString(text,seperator)
	parser = parser or csv.noParser
	local SEP = seperator or ","
	--print(parser("hey(hey)",false))
	local END = "\n"
	
	local out
	local headers = {}
	local column = 1
	local current = ""
	
	for i=1,text:len(),1 do
		local char = text:sub(i,i)
		if char==SEP then
			if out and current then
				current = tonumber(current) or current
				out[#out][headers[column]] = current
			else
				headers[column] = current
			end
			current = ""
			column = column + 1
		elseif char==END then
			--line ending shenanigans (a CR can otherwise get appended)
			current = current:trim()
			if out then
				current = tonumber(current) or current
				out[#out][headers[column]] = current
			else
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
	
	return out, headers
end

return csv
