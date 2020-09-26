# Allocator

A tool to place relays and keep track of channels more easily.
Objects are allocating in the order of (relay) execution.
Currently expects an empty level, and has no support for appending an existing level (yet).

## Creation
```Lua
instance = require("tools.allocator"):new(level,settings)
```
- level: the level to allocate stuff in
- settings: a table containing the settings:
	- immediate: whether the allocator should place objects immediatly upon allocation, or wait untill allocator:finalize(). Default is `false`.

## Allocating
```Lua
allocator:allocateRelay(receivingChannel, switchRequirements, sendingChannel)
```
Allocates a relay. Function arguments correspond with relay settings.

```Lua
obj = allocator:allocateObject(element)
```
- element: the name or id of the level element to allocate
- obj: an object that the allocator will make sure gets placed somewhere


```Lua
channel = allocater:allocateChannel()
```
- channel: a new unused channel

## Misc
```Lua
ralloc, calloc = allocator:getShortcuts()
```
- ralloc: a wrapper around `allocator:allocateRelay()` so you don't have to reference the allocator everytime
- calloc: a wrapper around `allocator:allocateChannel()` so you don't have to reference the allocator everytime

```Lua
allocator:finalize()
```
Actually places all objects when the immediate setting is off/false, errors otherwise.
Should only be called once.
