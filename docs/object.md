# Object

Represents an object.
There're two different versions: with or without properties.
Property objects extend base objects (they can do everything a base object can do).
Objects created by the LHS system are always property objects.

## Creation

#### For objects without properties:
```Lua
object = require("levelhead.objects.base"):new(id)
```
- id: the id or name of the level element this object is.

#### For objects with properties:
```Lua
object = require("levelhead.objects.propertiesBase"):new(id)
```
- id: the id or name of the level element this object is.

## Properties

```Lua
object:set[property name](value)
```
- property name: concatanated name of the poperty you're setting, where each word starts with with an uppercase letter
- value: the new value of said property

```Lua
value = object:get[property name]()
```
- property name: concatanated name of the poperty you're getting, where each word starts with with an uppercase letter
- value: the value of said property


```Lua
object:setProperty(id, mapping)
```
- id: the id/name of the property to change
- mapping: the new mapped value of said property

```Lua
mapping = object:getProperty(id)
```
- id: the id/name of the property to retrieve
- mapping: the mapped value of said property

```Lua
object:setPropertyRaw(id, value)
```
- id: the id/name of the property to change
- value: the new raw value of said property

```Lua
value = object:getPropertyRaw(id)
```
- id: the id/name of the property to retrieve
- value: the raw value of said property

## Base Info

```Lua
object.world
```
The __Level__ this object belongs to. Nil if it's not bound to a level. DO NOT edit this directly.

```Lua
object.layer
```
Whether this object is on the "foreground" or "background" layer of a __Level__. Nil if it's not bound to a level. DO NOT edit this directly.
