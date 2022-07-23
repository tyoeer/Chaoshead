# Path

Represents a path.
Nodes are their own datastructure, they're described further down.
Paths don't require be bound to a level (see Level:addPath) before nodes are added.

## Creation

```Lua
instance = require("levelhead.level.path"):new()
```
Creates a new path.

Also see `Level:newPath()` and `path:cloneWithoutNodes()`

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

### Chaining

To make node editing easier and cleaner, all methods return the path, usage looks like:

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
- property name: concatenated name of the property you're setting, where each new word starts with with an uppercase letter
- value: the new value of said property

```Lua
value = path:get[property name]()
```
- property name: concatenated name of the property you're getting, where each new word starts with with an uppercase letter
- value: the value of said property

```Lua
path:setProperty(selector, mapping)
```
- selector: the numerical id or properly capitalized name of the property to change
- mapping: the new mapped value of said property

```Lua
mapping = path:getProperty(selector)
```
- selector: the numerical id or properly capitalized name of the property to retrieve
- mapping: the mapped value of said property

```Lua
path:setPropertyRaw(id, value)
```
- id: the numerical id of the property to change
- value: the new raw value of said property

_WARNING_: this bypasses important checks. Only use this if you know what you're doing.

```Lua
value = path:getPropertyRaw(id)
```
- id: the numerical id of the property to retrieve
- value: the raw value of said property

_WARNING_: this bypasses important checks. Only use this if you know what you're doing.

### Chaining

To make setting multiple properties easier and cleaner, all property setters return the path, usage looks like:

```Lua
path:setProperty(selector, mapping)
    :setPropertyRaw(id, value)
    :set[property name](value)
```

### Meta

```Lua
for propertyId in path:iterateProperties() do
```
Iterates over all the properties paths have.

```Lua
has = path:hasProperty(propId)
```
- id: the _numerical id_ of the property to check
- has: whether or not paths have that property

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

## Other

```Lua
newPath = path:cloneWithoutNodes()
```
- newPath: a new path that has the same properties as `path`

Only copies properties, both nodes and which __World__ this path is in is _not_ copied.

```Lua
path:reverse()
```
Flips the direction this path is going.

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
In case of a closed path, these can point to itself.

```Lua
pathNode.path
```
The __Path__ this node belongs to. Nil if it's not bound to a path. DO NOT edit this directly.

## Path manipulation

```Lua
new = pathNode:append(x,y)
```
- x, y: the position to create a new path node at.
- new: the newly created node.

Adds a new node to the path right after this one. \
Errors if this node is not part of a path.

```Lua
new = pathNode:prepend(x,y)
```
- x, y: the position to create a new path node at.
- new: the newly created node.

Adds a new node to the path right before this one. \
Errors if this node is not part of a path.

## Manipulation

```Lua
other = pathNode:disconnectAfter()
```
- other: The new path containing all the nodes after this one if the path was split into two, nil otherwise.

Breaks the conenction to the next node.
Opens up a closed path, splits an open path into 2.

```Lua
other = pathNode:splitAfter()
```
- other: the new path containing all the nodes after this one

Splits all the nodes after this one into their own path.
Pretends the path is open.

```Lua
pathNode:makeHead()
```
Turns this node into the head/first node of its path.
Moves the gap in an open path to right before this one.
