local csv = require("utils.csv")
local Z = Class(require("levelhead.data.base"))

function Z:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/zones.tsv"),"\t")

	--parse headers
	self.headers = {}
	for i,v in ipairs(rawHeaders) do
		local raw = self:reduceSelector(v)
		if raw:match("^name$") then
			self.headers.name = v
		elseif raw:match("^music1$") then
			self.headers.music1 = v
		elseif raw:match("^music2$") then
			self.headers.music2 = v
		elseif raw:match("^music3$") then
			self.headers.music3 = v
		elseif raw:match("^music4$") then
			self.headers.music4 = v
		elseif raw:match("^musicambient$") then
			self.headers.musicAmbient = v
		elseif raw:match("iddecimal") then
			self.headers.id = v
		end
	end
end

function Z:getMusic1(selector)
	return self:getRow(selector)[self.headers.music1] or "$UnknownMusic"
end
function Z:getMusic2(selector)
	return self:getRow(selector)[self.headers.music2] or "$UnknownMusic"
end
function Z:getMusic3(selector)
	return self:getRow(selector)[self.headers.music3] or "$UnknownMusic"
end
function Z:getMusic4(selector)
	return self:getRow(selector)[self.headers.music4] or "$UnknownMusic"
end
function Z:getAmbientMusic(selector)
	return self:getRow(selector)[self.headers.musicAmbient] or "$UnknownMusic"
end

return Z:new()
