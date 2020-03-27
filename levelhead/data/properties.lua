local csv = require("utils.csv")
local P = Class(require("levelhead.data.base"))

function P:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/properties.tsv"),"\t")

	--parse headers
	self.headers = {}
	for i,v in ipairs(rawHeaders) do
		local raw = v:gsub("%W",""):lower()
		if raw:match("saveformat") then
			self.headers.saveFormat = v
		elseif raw:match("name") then
			self.headers.name = v
		elseif raw:match("iddecimal") then
			self.headers.id = v
		end
	end
end

function P:getSaveFormat(selector)
	return self:getRow(selector)[self.headers.saveFormat]
end

return P
