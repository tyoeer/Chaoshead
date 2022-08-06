# Allocator

A tool to place relays and keep track of channels more easily.
Objects are allocating in the order of (relay) execution.
Currently expects an empty level, and has no support for appending an existing level (yet).

## Creation

```Lua
allocator = require("tools.allocator"):new(level,settings)
```
- level: the level to allocate stuff in
- settings: a table containing the settings:
	- immediate: whether the allocator should place objects immediately upon allocation, or wait until allocator:finalize().
	  Default is `false`.
	- size: table containing the size of the area in which things should be allocated in the format `{width,height}`.
	  Use together with `setTopLeftCorner()` to limit the allocator to a specific area.
	  Defaults to the level size.
	- objectMask: whether the allocator should have a mask that limits where objects can be placed.
	  Required for area allocation. See `getObjectMask()` for more info.
	  Defaults to `false`
	- channelMask: whether the allocator should have a mask that limits which channels can be used.
	  See `getChannelMask()` for more info.
	  Defaults to `false`
	- preScan: whether to automatically scan the level and mask away anything already used.
	  Does not properly work with objects bigger than 1x1 due to data that still needs to be collected.
	  (Objects bigger than 1x1 will not get masked off completely, causing overlap, causing undefined behaviour in Levelhead.)
	  Defaults to `false`.

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
channel = allocator:allocateChannel()
```
- channel: a new unused channel  

```Lua
channels = allocator:allocateChannels(n)
```
It is possible to allocate a whole range of channels at once. This will allocate `n` channels and return them as an array `channels`.

```Lua
area = allocator:allocateArea(width, height)
```
- width, height: the size fo the area to allocate
- area: an allocator limited to the specified area

An objectMask is required for to prevent an area getting used for multiple things simultaneously.
There're no guarantees about the order in which areas are allocated, relating to objects and each other.

## Misc

```Lua
ralloc, calloc = allocator:getShortcuts()
```
- ralloc: a wrapper around `allocator:allocateRelay()` so you don't have to reference the allocator every time
- calloc: a wrapper around `allocator:allocateChannel()` so you don't have to reference the allocator every time

```Lua
allocator:finalize()
```
Actually places all objects when the immediate setting is off/false, errors otherwise.

```Lua
mask = allocator:getObjectMask()
```
- mask: (a reference to) the Bitplane masking where the allocator can place objects

Set a position to `false` to block it off from the allocator. All spaces default to `true`.

```Lua
mask = allocator:getChannelMask()
```
- mask: (a reference to) the table masking which channels can be used by the allocator.

Channels are the keys in the table.
Set a channel to `false` to block it off from the allocator. All channels default to `true`.

```Lua
allocator:setTopLeftCorner(x,y)
```
- x, y: the position of the top-left corner (inclusive)

Sets the top-left corner of the area in which things should be allocated.
Use together with the `size` setting to limit the allocator to a specific area.
