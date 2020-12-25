# Level

Represents a level.
Foreground and backgrounds objects can overlap, and are therefor split accross different 'layers'.
See the scripting documentation (in the README) for how to access the existing level when in a script
(TL;DR use the level global).

## Creation

```Lua
instance = require("levelhead.level"):new(width,height)
```
- width, height: the size of the level

## Editing the world

### Foreground

```Lua
Level:addObject(object,x,y)
```
- object: the foreground __Object__ to add to the world
- x, y: the position where to place the object

```Lua
obj = Level:place[element](x,y)
```
- element: concatanated name of the level element you're placing, where each word starts with with an uppercase letter
- x, y: the position where to place the object
- obj: the __Object__ that has been placed

Currently always places stuff on the foreground.

```Lua
Level:removeObject(object)
```
- object: the foreground __Object__ to remove from the world

```Lua
Level:removeForeground(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no foreground object at the specified coördinates, nothing will happen.

### Background

```Lua
Level:addBackgroundObject(object,x,y)
```
- object: the background __Object__ to add to the world
- x, y: the position where to place the object

```Lua
Level:removeBackgroundObject(object)
```
- object: the background __Object__ to remove from the world

```Lua
Level:removeBackground(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no background object at the specified coördinates, nothing will happen.

## Getting information from the world

```Lua
level.allObjects
```
Read-only __EntityPool__ with all the objects.

```Lua
level.foreground
```
Read-only __Grid__ with all the objects on the foreground layer.

```Lua
level.background
```
Read-only __Grid__ with all the objects on the background layer.

```Lua
level.width, level.height
```
The width and height of the level.
