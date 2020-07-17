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
		elseif raw:match("iddecimal") then
			self.headers.id = v
		end
	end
end

return E:new()
