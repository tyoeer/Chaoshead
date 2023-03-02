local JSON = require("libs.json")

local SETTINGS_FOLDER = "settings/"
local STORAGE_FOLDER = "storage/"

local base = select(1, ...).."."
local settings = {
	folder = SETTINGS_FOLDER,
	defaults = {},
}

-- COMMON

local function saveData(path,data)
	local success, err = love.filesystem.write(path, JSON.encode(data))
	if not success then
		error("Error saving settings: "..tostring(err))
	end
end

function settings:save(which)
	if type(self)=="string" then
		which = self
	end
	if not settings[which] then
		return
	end
	local filePath = SETTINGS_FOLDER..which..".json"
	saveData(filePath, settings[which])
end

local function loadData(path)
	--read settings
	local data, err = love.filesystem.read(path)
	if not data then
		error("Error reading settings: "..tostring(err))
	end
	local success, dataOrError = pcall(JSON.decode, data)
	if not success then
		error("Error parsing settings: "..tostring(dataOrError))
	end
	return dataOrError
end

-- SETTINGS

--check if we have a "settings/" directory in the save directory
if not love.filesystem.getRealDirectory(SETTINGS_FOLDER) ~= love.filesystem.getSaveDirectory() then
	love.filesystem.createDirectory(SETTINGS_FOLDER)
end

local function addDefaults(current,defaults, maxLevel,level)
	if level > maxLevel then
		return false
	end
	local changed = false
	for key, value in pairs(defaults) do
		if type(value)=="table" then
			if current[key]==nil then
				current[key] = value
				changed = true
			else
				--don't put it in the OR directly because it will get skipped cause of lazy evaluation
				local childChanged = addDefaults(current[key], defaults[key], maxLevel, level+1)
				changed = changed or childChanged
			end
		else
			if current[key]==nil then
				current[key] = value
				changed = true
			end
		end
	end
	return changed
end

local function load(name, maxLevel, ...)
	--how deep new settings still get added (in case some settings take a datastructure as value)
	local maxLevel = maxLevel or math.huge
	local defaults = require(base..name)
	settings.defaults[name] = defaults
	
	local changed = false
	
	local filePath = SETTINGS_FOLDER..name..".json"
	local fileInfo = love.filesystem.getInfo(filePath)
	if fileInfo then
		settings[name] = loadData(filePath)
		
		--check if a new setting has been added and save it
		changed = addDefaults(settings[name],defaults, maxLevel,1)
	else
		settings[name] = defaults
		changed = true
	end
	
	if changed then
		saveData(filePath, settings[name])
	end
	
	for _,alias in ipairs({...}) do
		settings[alias] = settings[name]
	end
end

load("bindings", 2, "keys")
load("misc")
load("theme")

-- STORAGE

--check if we have a "storage/" directory in the save directory
if not love.filesystem.getRealDirectory(STORAGE_FOLDER) ~= love.filesystem.getSaveDirectory() then
	love.filesystem.createDirectory(STORAGE_FOLDER)
end



local function getStoragePath(storage)
	if type(storage)=="table" then
		storage = storage.storageName
	end
	return STORAGE_FOLDER..storage..".json"
end

local saveStorage
saveStorage = function(self)
	--make sure we don't try to save this function
	self.save = nil
	saveData(getStoragePath(self), self)
	self.save = saveStorage
end

local storage = {
	settings = settings
}

function storage:get(name)
	if not self[name] then
		local path = getStoragePath(name)
		
		local store
		if love.filesystem.getInfo(path) then
			store = loadData(path)
		else
			store = {}
		end
		store.save = saveStorage
		store.storageName = name 
		
		self[name] = store
	end
	return self[name]
end

return storage
