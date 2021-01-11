# Path

Represents a path.
Nodes are their own datastructure, they're described further down.
Paths should be bound to a level (see Level:addPath) BEFORE nodes are added.

## Creation

```Lua
instance = require("levelhead.path"):new()
```
Creates a new path.

Also see `Level:newPath()`

## Adding nodes

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

# PathNode

Nodes contain some internal drawing code, which is why they're a whole datastructure.

## Creation

```Lua
local _, PN = require("levelhead.path")
instance = PN:new(x,y)
```
- x, y: the position to create tha path node at

## Info

```Lua
x, y = pathNode.x, pathNode.y
```
- x, y: the Read-only position of this node

```Lua
prev, next = pathNode.prev, pathNode.next
```
- prev, next: the Read-only nodes before and after this one repsectively. Nil if those don't exist.

```Lua
path = pathNode.path
```
- path: the __Path__ this node belongs to. Nil if it's not bound to a path.
