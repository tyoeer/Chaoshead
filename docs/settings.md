# Settings

Represents the settings of a level.


## Creation

```Lua
settings = require("levelhead.level.settings"):new()
```
Creates a new group of settings.

Also see [Level](level.md)`.settings`

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
The minimum amount of players required to play this level. Should be a number between 1 and 4 inclusive.

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

There's currently no way to set the title because I haven't made something yet to work around/with Name Combobulator limitations.

```Lua
major, minor, patch = settings:getLevelheadVersion()
```
The semantic version of Levelhead this level was last edited/saved with.

```Lua
settings:setLevelheadVersion(major,minor,patch)
```
The semantic version of Levelhead this level was last edited/saved with.

```Lua
settings.legacyVersion
```
No longer used by Levelhead, defaults to 11000. Can not be larger than 65535.

```Lua
settings.mode
```
Represents which mode a level is in. See the File Format document for more info. Is a byte.

```Lua
settings.zoomLevel
```
See the File Format document for more information. Is a float.

```Lua
settings.published
```
_You probably shouldn't edit this._ See the File Format document what this does. Is a boolean.

## DEPRECATED

```Lua
settings.prefix
```
Raw access to the first 6 bytes, which form the legacy and Levelhead version.

```Lua
settings.campaignMarker
```
_You probably shouldn't edit this._ Numerical version of the `published` field.
