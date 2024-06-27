--[[

TODO
- Better file select
- Note velocity is 0-127, that needs to be adjusted
- Property ranges:
	- Too many note beats
	- Notes that are too short
- Better organisation of limits:
	- Tempo changes
	- Missing precussion
	- OOB pitches
- Compression of the amount of boomboxes

]]

local midiNotes = {
	"C",false,
	"C",true,
	"D",false,
	"D",true,
	"E",false,
	"F",false,
	"F",true,
	"G",false,
	"G",true,
	"A",false,
	"A",true,
	"B",false,
}
-- 35,39,41,43,45,48,66,80,81,82,
local perc = {
	["Kick Deep"] = {35},
	["Kick Thump"] = {36},
	["Snare Tough"] = {37,38,40},
	["Snare Slap"] = {66},
	["Snare Reverb"] = {51},
	["Hi-Hat Tap"] = {80,44},
	["Hi-Hat Close"] = {81,42},
	["Hi-Hat Open"] = {59,46},
	["Crash"] = {52,49,57},
	["Tom Low"] = {45,47},
	["Tom High"] = {48,50},
	["Tom Low Soft"] = {41},
	["Tom High Soft"] = {43,60},
	["Click"] = {39,82},
	["Click Soft"] = {69},
}

local function midiToPerc(midi)
	for k,v in pairs(perc) do
		for _,vv in ipairs(v) do
			if vv==midi then
				return k
			end
		end
	end
end
local function midiToNote(midi)
	local octave = math.floor(midi/12)-1
	local i = (midi%12)
	local note = midiNotes[2*i+1]
	return note..octave
end
local function isSharp(midi)
	return midiNotes[2*(midi%12)+2]
end


-- Script global state


local alloc
local tempo
local ticksPerBeat


-- Functions depending on script global state


local function ticksToBeat(ticks)
	return ticks/ticksPerBeat
end

local function boombox(note,delay,duration,volume,isPerc)
	local b = alloc:allocateObject("Boombox")
	b:setInvisible("Yes")
	
	if isPerc then
		b:setPercussionNote(midiToPerc(note))
		b:setInstrument("Percussion")
	else
		if note >= 48 then
			b:setMelodyPitch(midiToNote(note))
			b:setInstrument("Melody")
		else
			b:setBassPitch(midiToNote(note))
			b:setInstrument("Bass")
		end
	end
	if isSharp(note) then
		b:setSharp("Yes")
	else
		b:setSharp("No")
	end
	b:setBeatsPerMinute(tempo)
	b:setStartDelayBeats(delay)
	b:setNoteBeats(duration)
	b:setReceivingChannel(999)
	b:setSwitchRequirements("Any Inactive")
	b:setVolume(volume)
	
	selection.mask:add(b.x, b.y)
end

--field indices in the event

local TYPE = 1
local START_TIME = 2
local DURATION = 3
local TEMPO = 3--set_tempo event
local CHANNEL = 4
local NOTE = 5
local VELOCITY = 6

--https://gitlab.com/peterbillam/miditools/
--https://peterbillam.gitlab.io/pjb_lua/lua/MIDI.html#changes
local M = require("libs.midi")

alloc = require("tools.allocator"):new(level, {objectMask=true, preScan=true, immediate=true, scanBgObjects=false})

if not selection then
	selection = {}
end
selection.mask = require("tools.selection.mask"):new()
selection.mask:setLayerEnabled("background",false)
selection.mask:setLayerEnabled("pathNodes",false)

local raw, nRaw = love.filesystem.read("scripts/mysteryProjectA/import.mid")
local score = M.midi2score(raw)

ticksPerBeat = score[1]
print(ticksPerBeat,#score[2],nRaw)



local missing_percussion={}
for track=2,#score,1 do
	for _i,event in ipairs(score[track]) do
		local event_values = "{"
		for _,w in ipairs(event) do
			event_values = event_values..w..","
		end
		event_values = event_values.."}"
		--print(i,vs)
		if event[TYPE]=="set_tempo" and not tempo then
			tempo = 60/(event[TEMPO]/10^6)
			print(tempo)
		elseif event[TYPE]=="note" then
			--print(v[4])
			--print(midiToNote(v[5]),ticksToBeat(v[2]),ticksToBeat(v[3]),v[6])
			if event[NOTE] < 33 then
				print(string.format("Note %s at beat %i too low!",midiToNote(event[5]),ticksToBeat(event[2])))
			elseif event[NOTE] > 96 then
				print(string.format("Note %s at beat %i too high!",midiToNote(event[5]),ticksToBeat(event[2])))
			else
				if event[CHANNEL]==9 then
					if midiToPerc(event[NOTE]) then
						boombox(event[NOTE],ticksToBeat(event[START_TIME]),ticksToBeat(event[DURATION]),event[VELOCITY],true)
					else
						table.insert(missing_percussion,event[NOTE])
					end
				else
					boombox(event[NOTE],ticksToBeat(event[START_TIME]),ticksToBeat(event[DURATION]),event[VELOCITY],false)
				end
			end
		end
	end
end
--print used percussion
table.sort(missing_percussion)
local o = ""
local had ={}
for _,v in ipairs(missing_percussion) do
	if not had[v] then
		o = o..v..","
		had[v] = true
	end
end
print("Percussion not found: "..o)

