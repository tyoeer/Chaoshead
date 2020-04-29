# Level
Represents a level.

## Getting a level instance

```Lua
instance = level.class:new(width,height)
```
- width, height: the size of the level
- instance: the instance representing the level

```Lua
instance = LHS:parseAll()
```
- LHS: an instance of from the LHS system, from which everything has already been read (with `LHS:readAll()`)

```Lua
instance = level
```
- level: a global variable containing the level currently in the editor

## Editing the world

```Lua
Level:addObject(object,x,y)
```
- object: the __Object__ to add to the world
- x, y: the position where to place the object

```Lua
obj = Level:place[element](x,y)
```
- element: concatanated name of the level element you're placing, where each word starts with with an uppercase letter
- x, y: the position where to place the object
- obj: the __Object__ that has been placed

```Lua
Level:removeObject(object)
```
- object: the __Object__ to remove from the world

```Lua
Level:removeForeground(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no foreground object at the specified coördinates, nothing will happen.

## Getting information from the world

```Lua
level.allObjects
```
Read-only __EntityPool__ with all the objects.

```Lua
level.foreground
```
Read-only __Grid__ with all the objects on the foreground layer.
