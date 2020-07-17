local csv = require("utils.csv")
local E = Class(require("levelhead.data.base"))

function E:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/levelElements.tsv"),"\t")
	
	--parse headers
	self.headers = {}
	for i,v in ipairs(rawHeaders) do
		local raw = v:gsub("%W",""):lower()
		if raw:match("^name$") then
			self.headers.name = v
		elseif raw:match("^iddecimal$") then
			self.headers.id = v
		elseif raw:match("width") then
			self.headers.width = v
		elseif raw:match("height") then
			self.headers.height = v
		end
	end
end

function E:getWidth(selector)
	return self:getRow(selector)[self.headers.width] or "$UnknownWidth"
end

function E:getHeight(selector)
	return self:getRow(selector)[self.headers.height] or "$UnknownHeight"
end

function E:getSize(selector)
	local r = self:getRow(selector)
	return r[self.headers.width] or "$UnknownWidth", r[self.headers.height] or "$UnknownHeight"
end

return E:new()
