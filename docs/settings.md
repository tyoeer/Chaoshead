# Settings

Represents the settings of a level.


## Creation

```Lua
settings = require("levelhead.level.settings"):new()
```
Creates a new group of settings.

Also see __Level__`.settings`

## Settings



```Lua
settings:setZone(zone)
```
```Lua
zone = settings:getZone()
```
- zone: Input can be name or id, output is always the name. See the data spreadsheet for available zones.

```Lua
settings:setMusic(music)
```
```Lua
music = settings:getMusic()
```
- song: Input can be name or id, output is always the name. See the data spreadsheet for available songs.

```Lua
settings.minimumPlayers
```
The minimum amonut of players required to play this level. Should be a number between 1 and 4 inclusive.

```Lua
settings.playersSharePowerups
```
Whether or not powerups should be distributed to all players when one collects one. Is a boolean.

```Lua
settings.weather
```
Whether or not the weather effect should be on at the start of the level. Is a boolean.

```Lua
settings:setLanguage(language)
```
```Lua
language = settings:getLanguage()
```
- language: Input can be English name or id, output is always the name. See the data spreadsheet for available songs.

```Lua
settings:setMultiplayerRespawnStyle(style)
```
```Lua
style = settings:getMultiplayerRespawnStyle()
```
- style: one of the following:
	- "Bubble": Dead players become a bubble, and respawn when the bubble reaches a still-alive player.
	- "BUDD-E": Dead players only come alive upon reaching a checkpoint.

Which style of multiplayer respawning to use.

```Lua
settings.stopCameraAtLevelSides
```
Whether or not the camera should stay between the _horizontal_ level sides. Is a boolean. Corresponds to "Horizontal Camera Boundary" in Levelhead.

```Lua
title = settings:getTitle()
```
- title: string containing the level title.

There's currently no way to set the title because I haven't made something yet to work around name combobulator limitations.

```Lua
settings.prefix
```
Unknown what it does, probably related to the level version. See the File Format document for more info. Is a 6 bytes long string.

```Lua
settings.campaignMarker
```
partially unknown what it does, but can differ between levels. _You probably shouldn't edit this._ See the File Format document for more info. Is a byte.

```Lua
settings.mode
```
Used for dev-only stuff. _You probably shouldn't touch this._ See the File Format document for more info. Is a byte.
