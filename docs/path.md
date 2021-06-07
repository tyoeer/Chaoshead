# Path

Represents a path.
Nodes are their own datastructure, they're described further down.
Paths don't require be bound to a level (see Level:addPath) before nodes are added.

## Creation

```Lua
instance = require("levelhead.level.path"):new()
```
Creates a new path.

Also see `Level:newPath()`

## Editing nodes

```Lua
path:append(x,y)
```
- x, y: the position to create the new node at

Creates a new node that gets added to the end of the path.

```Lua
path:addNodeAfter(new,anchor)
```
- new: the __PathNode__ to add to the path
- anchor: the __PathNode__ after which `new` should be placed

```Lua
path:addNodeBefore(new,anchor)
```
- new: the __PathNode__ to add to the path
- anchor: the __PathNode__ before which `new` should be placed

```Lua
path:removeNode(node)
```
- node: the __PathNode__ to remove

to make node editing easier and cleaner, all methods return __this__, usage looks like
```Lua
path:append(x,y)
    :addNodeAfter(new, anchor)
    :addNodeBefore(new, anchor)
    :removeNode(node)
```

## Properties

```Lua
path:set[property name](value)
```
- property name: concatanated name of the poperty you're setting, where each new word starts with with an uppercase letter
- value: the new value of said property

```Lua
value = path:get[property name]()
```
- property name: concatanated name of the poperty you're getting, where each new word starts with with an uppercase letter
- value: the value of said property

```Lua
path:setProperty(id, mapping)
```
- id: the id/name of the property to change
- mapping: the new mapped value of said property

```Lua
mapping = path:getProperty(id)
```
- id: the id/name of the property to retrieve
- mapping: the mapped value of said property

```Lua
path:setPropertyRaw(id, value)
```
- id: the id/name of the property to change
- value: the new raw value of said property

```Lua
value = path:getPropertyRaw(id)
```
- id: the id/name of the property to retrieve
- value: the raw value of said property

### Chaining

To make setting multiple properties easier and cleaner, all property setters return the path, usage looks like:

```Lua
path:setProperty(id, mapping)
    :setPropertyRaw(id, value)
    :set[property name](value)
```

### Meta

```Lua
for propertyId in object:iterateProperties() do
```
Iterates over all the properties this object has.

## Info

```Lua
path.head, path.tail
```
The Read-only first and last __PathNode__s of this path respectively.

```Lua
path.world
```
The __World__ this path belongs to. Nil if it's not bound to a level. DO NOT edit this directly.

```Lua
for node in path:iterateNodes() do
```
A generic for iterator that iterates over all the nodes in this path from head to tail.

# PathNode

Nodes contain some internal drawing code, which is why they're a whole datastructure.

## Creation

```Lua
instance = require("levelhead.level.pathNode"):new(x,y)
```
- x, y: the position to create tha path node at

## Info

```Lua
pathNode.x, pathNode.y
```
The Read-only position of this node

```Lua
pathNode.prev, pathNode.next
```
The Read-only nodes before and after this one repsectively. Nil if those don't exist.

```Lua
pathNode.path
```
The __Path__ this node belongs to. Nil if it's not bound to a path. DO NOT edit this directly.
