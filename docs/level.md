# Level

Represents a level or world.
Two variations exist __Level__ and __World__: level = world + misc. settings.
Foreground and backgrounds objects can overlap, and are therefore split accross different 'layers'.
See the scripting documentation (in the README) for how to access the existing level when in a script
(TL;DR use the level global).

## Creation

```Lua
level = require("levelhead.level.level"):new(width,height)
```
- width, height: the size of the level

```Lua
world = require("levelhead.level.world"):new(width,height)
```
- width, height: the size of the world

## Editing the world

### Foreground & Background

```Lua
world:removeObject(object)
```
- object: the __Object__ to remove from the world

### Foreground

```Lua
world:addForegroundObject(object,x,y)
```
- object: the foreground __Object__ to add to the world
- x, y: the position where to place the object

```Lua
world:addObject(...)
```
Currently an alias for `Level:addForegroundObject(...)`

```Lua
object = world:place[element](x,y)
```
- element: concatanated name of the level element you're placing, where each word starts with with an uppercase letter
- x, y: the position where to place the object
- obj: the __Object__ that has been placed

Currently always places stuff on the foreground.

```Lua
world:removeForegroundAt(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no foreground object at the specified coördinates, nothing will happen.

### Background

```Lua
world:addBackgroundObject(object,x,y)
```
- object: the background __Object__ to add to the world
- x, y: the position where to place the object

```Lua
world:removeBackgroundAt(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no background object at the specified coördinates, nothing will happen.

### Paths

```Lua
path = Level:newPath()
```
- path: a new __Path__ added to this world

```Lua
world:addPath(path)
```
- path: the __Path__ to add to this world

```Lua
world:removePath(path)
```
- path: the __Path__ to remove from this world

```Lua
world:removePathNodeAt(x,y)
```
- x,y: the position of the path node to remove

In case there's no path node at the specified coördinates, nothing will happen.


## Getting information from the world

```Lua
world.objects
```
Read-only __EntityPool__ with all the objects.

```Lua
world.paths
```
Read-only __EntityPool__ with all the paths.

```Lua
world.foreground
```
Read-only __Grid__ with all the objects on the foreground layer.

```Lua
world.background
```
Read-only __Grid__ with all the objects on the background layer.

```Lua
world.pathNodes
```
Read-only __Grid__ with all the path nodes.

```Lua
world.width, world.height
```
The width and height of the world.
