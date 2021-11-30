local JSON = require("libs.json")

local SETTINGS_FOLDER = "settings/"
local STORAGE_FOLDER = "storage/"

local base = select(1, ...).."."
local out = {}

-- COMMON

local function saveData(path,data)
	local success, err = love.filesystem.write(path, JSON.encode(data))
	if not success then
		error("Error saving settings: "..tostring(err))
	end
end

local function loadData(path)
	--read settings
	local data, err = love.filesystem.read(path)
	if not data then
		error("Error reading settings: "..tostring(err))
	end
	success, dataOrError = pcall(JSON.decode, data)
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
	
	local changed = false
	
	local filePath = SETTINGS_FOLDER..name..".json"
	local fileInfo = love.filesystem.getInfo(filePath)
	if fileInfo then
		out[name] = loadData(filePath)
		
		--check if a new setting has been added and save it
		changed = addDefaults(out[name],defaults, maxLevel,1)
	else
		out[name] = defaults
		changed = true
	end
	
	if changed then
		saveData(filePath, out[name])
	end
	
	for _,alias in ipairs({...}) do
		out[alias] = out[name]
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

local storagePath = STORAGE_FOLDER.."data.json"

--load the storage
if love.filesystem.getInfo(storagePath) then
	out.storage = loadData(storagePath)
else
	out.storage = {}
end

local saveStorage = function()
	--make sure we don't try svaing this function
	out.storage.save = nil
	saveData(storagePath, out.storage)
	out.storage.save = saveStorage
end

out.storage.save = saveStorage

return out
