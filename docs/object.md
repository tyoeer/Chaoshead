Represents an object.
- require("levelhead.objects.base") for base functionality.
- require("levelhead.objects.propertiesBase") for objects with properties.

# Base
```Lua
instance = object.class:new(id)
```
- id: the id of the level element this object is.
- instance: the instance representing said object

```Lua
object:draw()
```
It errors if the object isn't in a world.

# Properties

```Lua
object:set[property name](value)
```
- property name concatanated name of the poperty you're setting, where each word starts with with an uppercase letter
- the new value of said property

```Lua
value = object:get[property name]()
```
- property name concatanated name of the poperty you're setting, where each word starts with with an uppercase letter
- value: the value of said property

```Lua
object:setPropertyRaw(id, value)
```
- id: the id/name of the property to change
- value: the new value of said property

```Lua
object:getPropertyRaw(id)
```
- id: the id/name of the property to retrieve
