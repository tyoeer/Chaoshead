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
	- immediate: whether the allocator should place objects immediatly upon allocation, or wait untill allocator:finalize().
	  Default is `false`.
	- size: table containing the size of the area in which things should be allocated in the format `{width,height}`.
	  Use together with `setTopLeftCorner()` to limit the allocator to a specific area.
	  Defaults to the level size.
	- mask: wether the allocator should have a mask that limits where things can be placed.
	  See `getMask()` for more info.
	  Defaults to `false`

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

```Lua
area = allocator:allocateArea(width, height)
```
- width, height: the size fo the area to allocate
- area: an allocator limited to the spcified area

There're no guarantees about the order in which areas are allocated, relating to objects and each other.

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

```Lua
mask = allocator:getMask()
```
- mask: (a reference to) the Bitplane masking where the allocator can place objects

Set a position to `false` to block it off from the allocator. All spaces default to `true`.

```Lua
allocator:setTopLeftCorner(x,y)
```
- x, y: the position of the top-left corner (inclusive)

Sets the top-left corner of the area in which things should be allocated.
Use togetether with the `size` setting to limit the allocator to a specific area.
