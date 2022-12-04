# Object

Represents an object.
An object can have properties set or can contain object even if it can't in Levelhead,
in which case Levelhead tends to ignore it.


## Creation

```Lua
object = require("levelhead.level.object"):new(id)
```
- id: the id or name of the level element this object is.

Also see `Object:clone()`

## Properties

### Setting

```Lua
object:set[property name](value)
```
- property name: concatenated name of the property you're setting, where each word starts with with an uppercase letter
- value: the new value of said property

```Lua
object:setProperty(selector, mapping)
```
- selector: the numerical id or properly capitalized name of the property to change
- mapping: the new mapped value of said property

```Lua
object:setPropertyRaw(id, value)
```
- id: the numerical of the property to change
- value: the new raw value of said property

_WARNING_: this bypasses important checks. Only use this if you know what you're doing.

#### Chaining

To make setting multiple properties easier and cleaner, all property setters return the object, usage looks like:
```Lua
object:setProperty(selector, mapping)
      :setPropertyRaw(id, value)
      :set[property name](value)
```

### Getting

```Lua
value = object:get[property name]()
```
- property name: concatenated name of the property you're getting, where each word starts with with an uppercase letter
- value: the value of said property

```Lua
mapping = object:getProperty(selector)
```
- selector: the numerical id or properly capitalized name of the property to retrieve
- mapping: the mapped value of said property

```Lua
value = object:getPropertyRaw(id)
```
- id: the numerical id of the property to retrieve
- value: the raw value of said property

_WARNING_: this bypasses important checks. Only use this if you know what you're doing.

### Meta

```Lua
has = object:hasProperties()
```
- has: a boolean indicating if this object has properties or not

```Lua
for propertyId in object:iterateProperties() do
```
Iterates over all the properties this object has.

```Lua
has = object:hasProperty(id)
```
- id: the numerical id of the property to check
- has: whether or not this objects has that property

## Contained Objects

```Lua
object:setContents(element)
object:setContainedObject(element)
object:setThingInsideThisThing(element)
```
- element: the name/id of the element to become this object's contents/contained object

```Lua
element = object:getContents()
element = object:getContainedObject()
element = object:getThingInsideThisThing()
```
- element: the name of the element that this object contains

## Info

```Lua
name = object:getName()
```
The name of the level element this object is.

```Lua
isIt = object:isElement(element)
```
- element: name/id of the element

Returns whether or not this object is of the specified level element

```Lua
object.x, object.y
```
The position of the object. Nil if it hasn't been placed yet. DO NOT edit this directly. (use **World**`:moveObject()` instead)

```Lua
object.world
```
The __World__ this object belongs to. Nil if it's not bound to a level. DO NOT edit this directly.

```Lua
object.layer
```
Whether this object is on the "foreground" or "background" layer of a __Level__. Nil if it's not bound to a level. DO NOT edit this directly.

## Other

```Lua
newObject = object:clone()
```
- newObject: a new object that is a duplicate of `object`