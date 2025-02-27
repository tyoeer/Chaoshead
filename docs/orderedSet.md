# Ordered Set

Basically a list, but can more easily check if something is in it or remove something from it.
Often gets used as just a set, with no regards for the order.

The ends/edges of the set are called the "top" and "bottom".
The order of elements is how you insert them, if the last inserted item is at the top or the bottom depends on the method used (top for `:add()`).
"Things" in this set are referred to as "items".


## Creation


```lua
set = require("utils.orderedSet"):new()
```


## Addition


```lua
success = set:addAtTop(item)
```
- item: the new item to add at the top this set
- success: `true` if it got added, `false` if value was already in this set

```lua
success = set:addAtBottom(item)
```
- item: the new item to add at the bottom this set
- success: `true` if it got added, `false` if value was already in this set

```lua
success = set:add(item)
```
Alias for `set:addAtTop()`


## Removal


```lua
success = set:remove(item)
```
- item: item to remove from this set
- success: true if the item was removed, false if the item wasn't in the set

```lua
topItem = set:removeTop()
```
- topItem: item that used to be at the top of this set. `nil` if the set was empty.

Removes the item at the top of this set.

```lua
bottomItem = set:removeBottom()
```
- bottomItem: item that used to be at the bottom of this set. `nil` if the set was empty.

Removes the item at the bottom of this set.


## Retrieving


```lua
topItem = set:getTop()
```
- topItem: the item at the top of th set, `nil` if the set is empty

```lua
bottomItem = set:getBottom()
```
- bottomItem: the item at the bottom of th set, `nil` if the set is empty

```lua
for item in set:iterateDownwards() do
```
Iterates downwards over all item in the pool, from top to bottom.

```lua
for item in set:iterateUpwards() do
```
Iterates upwards over all item in the pool, from bottom to top.

```lua
for item in set:iterate() do
```
Alias for `set:iterateUpwards()`.


## Info 


```lua
size = set:size()
```
- size: how many items there are in this set

```lua
hasItem = set:has(item)
```
- item: the item to check for
- hasItem: `true` if `item` is in the set, `false` otherwise
