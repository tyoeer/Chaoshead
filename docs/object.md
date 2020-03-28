Represents an object.

# Base
```Lua
object.class:new(id)
```
- id: the id of the level element this object is.

```Lua
object:draw()
```
It errors if the object isn't in a world.

# Properties

```Lua
object:setPropertyRaw(id, value)
```
- id: the id/name of the property to change
- value: the new value of said property

```Lua
object:getPropertyRaw(id)
```
- id: the id/name of the property to retrieve
