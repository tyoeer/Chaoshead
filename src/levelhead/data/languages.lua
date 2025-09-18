local csv = require("utils.csv")
local L = Class(require("levelhead.data.base"))

function L:initialize()
	--parse data file
	local rawHeaders
	self.data, rawHeaders = csv.parseString(love.filesystem.read("data/languages.tsv"),"\t")

	--parse headers
	self.headers = {}
	for i,v in ipairs(rawHeaders) do
		local raw = self:reduceSelector(v)
		if raw:match("^nameenglish$") then
			self.headers.name = v
		elseif raw:match("^namenative$") then
			self.headers.native = v
		elseif raw:match("iddecimal") then
			self.headers.id = v
		end
	end
end

function L:getNativeName(selector)
	return self:getRow(selector)[self.headers.native] or "$UnknownNativeName"
end

return L:new()
