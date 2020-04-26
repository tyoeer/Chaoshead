Represents a level.


```Lua
instance = level.class:new(width,height)
```
- width, height: the size of the level
- instance: the instance representing the level

Levels can also be loaded from disk using the LHS system

```Lua
Level:addObject(object,x,y)
```
- object: the __Object__ to add to the world
- x, y: the position where to place the object

```Lua
Level:removeObject(object)
```
- object: the __Object__ to remove from the world

```Lua
Level:removeForeground(x,y)
```
- x, y: the position of the foreground __Object__ to remove

In case there's no foreground object at the specified coördinates, nothing will happen.

```Lua
level.allObjects
```
Read-only __EntityPool__ with all the objects.

```Lua
level.foreground
```
Read-only __Grid__ with all the objects on the foreground layer.
