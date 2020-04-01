Represents a level.


```Lua
level.class:new(width,height)
```
 - width, height: the size of the level

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
level.allObjects
```
Read-only __EntityPool__ with all the objects.

```Lua
level.foreground
```
Read-only __Grid__ with all the objects on the foreground layer.