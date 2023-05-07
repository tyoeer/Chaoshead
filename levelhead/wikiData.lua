local NFS = require("libs.nativefs")
local LhMisc = require("levelhead.misc")
local JSON = require("libs.json")
local E = require("levelhead.data.elements")

local wikiPath = LhMisc.getDataPath() .. "Wiki/"

---@class LHWikiData : Object
---@field new fun(self): self
local W = Class("LHWikiData")

function W:initialize()
	if not NFS.getInfo(wikiPath) then
		return
	end
	local dataPath = wikiPath.."GameData.json"
	if not NFS.getInfo(dataPath) then
		return
	end
	self.data = JSON.decode(NFS.read(dataPath))
	self.images = self:buildImages()
	---@type table<number, love.Image|nil>
	self.imageLookup = self.images
end

function W:buildImages()
	local images = {}
	
	local nameLookup = {}
	for _,element in ipairs(self.data.EditorItems) do
		nameLookup[element.Name] = element
	end
	
	for id=0, E:getHighestID() do
		local root = E:getRootParentId(id)
		if images[root] then
			images[id] = images[root]
		else
			local elem = nameLookup[E:getName(root)]
			if elem then
				local imgName = elem.Images and elem.Images[1]
				if imgName then
					local imgPath = wikiPath.."Images/"..imgName
					local imgData = NFS.read("data", imgPath)
					images[id] = love.graphics.newImage(imgData, {mipmaps = true})
				end
			end
		end
	end
	
	return images
end

---@param id number
function W:getImage(id)
	return self.images[id]
end

return W:new()