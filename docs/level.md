# Level

Represents a level or world.
Two variations exist: __Level__ and __World__: level = world + settings.
Foreground and backgrounds objects can overlap, and are therefore split across different 'layers'.
Worlds allow objects to be placed outside their bounds, but those can't be saved.
The x and y axes increase towards the right and bottom respectively.
See the scripting documentation (in the README) for how to access the existing __Level__ when in a script
(TL;DR use the `level` global).

## Creation

```Lua
level = require("levelhead.level.level"):new()
```

```Lua
world = require("levelhead.level.world"):new()
```

## Editing the world

### Foreground & Background

```Lua
world:addObject(object, x, y)
```
- object: the __Object__ to add to the world
- x, y: the position where to place the object

Tries to automatically determine the layer to add the object to.

```Lua
world:moveObject(obj,x,y)
```
- obj: the __Object__ to move.
- x, y: the position to move it to.

Automatically selects the right function to use depending on whether the object is on the foreground or background layer.

```Lua
world:removeObject(object)
```
- object: the __Object__ to remove from the world

```Lua
object = world:place[element](x,y)
```
- element: concatenated name of the level element you're placing, where each word starts with with an uppercase letter
- x, y: the position where to place the object
- obj: the __Object__ that has been placed

### Foreground

```Lua
world:addForegroundObject(object,x,y)
```
- object: the foreground __Object__ to add to the world
- x, y: the position where to place the object

```Lua
world:moveForegroundObject(obj,x,y)
```
- obj: the foreground __Object__ to move.
- x, y: the position to move it to..

Should not be with on background objects.

```Lua
world:removeForegroundAt(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no foreground object at the specified coordinates, nothing will happen.

### Background

```Lua
world:addBackgroundObject(object,x,y)
```
- object: the background __Object__ to add to the world
- x, y: the position where to place the object

```Lua
world:moveBackgroundObject(obj,x,y)
```
- obj: the background __Object__ to move.
- x, y: the position to move it to..

Should not be with on foreground objects.

```Lua
world:removeBackgroundAt(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no background object at the specified coordinates, nothing will happen.

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
world:movePathNode(node,x,y)
```
- node: the __PathNode__ to move.
- x, y: the position to move it to.

```Lua
world:removePathNodeAt(x,y)
```
- x,y: the position of the path node to remove

In case there's no path node at the specified coordinates, nothing will happen.


## Misc

```Lua
world.objects
```
Read-only __OrderedSet__ with all the objects.

```Lua
world.paths
```
Read-only __OrderedSet__ with all the paths.

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
world.left, world.top, world.right, world.bottom
```
The boundaries of the world (inclusive). Are only relevant for saving. Left should always be less than right, and top should always be less than bottom.

```Lua
width = world:getWidth()
```
- width: how many tiles fit within this worlds bounds along the x axis.

```Lua
height = world:getHeight()
```
- height: how many tiles fit within this worlds bounds along the y axis.

```Lua
level.settings
```
The __Settings__ of this level. Not available for **World**s.
