# Allocator

A tool to place objects and keep track of channels & rift IDs more easily.
Objects are allocating in the order of (relay) execution.
Currently expects an empty level, and has no support for appending an existing level (yet).

## Creation

```Lua
allocator = require("tools.allocator"):new(level,settings)
```
- `level`: the level to allocate stuff in
- `settings`: a table of the settings:
	- `immediate`: whether the allocator should place objects immediately upon allocation, or wait until `allocator:finalize()`.
	  Default is `false`.
	- `size`: table containing the size of the area in which things should be allocated in the format `{width,height}`.
	  Use together with `setTopLeftCorner()` to limit the allocator to a specific area.
	  Default is the size of `level`.
	- `objectMask`: whether the allocator should have a mask that limits where objects can be placed.
	  Required for area allocation. See `getObjectMask()` for more info.
	  Defaults to `false`
	- `channelMask`: whether the allocator should have a mask that limits which channels can be used.
	  See `getChannelMask()` for more info.
	  Defaults to `false`
	- `riftIdMask`: whether the allocator should have a mask that limits which rift IDs can be used.
	  See `getRiftIdMask()` for more info.
	  Defaults to `false`
	- preScan: whether to automatically scan the level and mask away anything already used.
	  Does not properly work with objects bigger than 1x1 due to data that still needs to be collected.
	  (Objects bigger than 1x1 will not get masked off completely, causing overlap, causing undefined behaviour in Levelhead.)
	  Defaults to `false`.

## Allocating

```Lua
relay = allocator:allocateRelay(receivingChannel, switchRequirements, sendingChannel)
rift = allocator:allocateRift(riftId, receivingChannel, switchRequirements, destinationRiftId)
```
Allocates a relay or rift and returns the allocated object. Function arguments correspond to their ingame properties.

```Lua
obj = allocator:allocateObject(element)
```
- `element`: the name or id of the level element to allocate
- `obj`: an object that the allocator will make sure gets placed somewhere

```Lua
channel = allocator:allocateChannel()
channels = allocator:allocateChannels(n)

id = allocator:allocateRiftId()
ids = allocator:allocateRiftIds(n)
```
- `channel`: a new unused channel
- `channels`: a table containing `n` distinct unused channels
- corresponding functions for rift ID allocation

```Lua
area = allocator:allocateArea(width, height)
```
- `width, height`: the size fo the area to allocate
- `area`: an allocator limited to the specified area

An `objectMask` is required for to prevent an area getting used for multiple things simultaneously.
There're no guarantees about the order in which areas are allocated, relating to objects and each other.

## Misc

```Lua
ralloc, calloc, idalloc = allocator:getShortcuts()
```
- `ralloc`: a wrapper around `allocator:allocateRelay()` so you don't have to reference the allocator every time
- `calloc`: a wrapper around `allocator:allocateChannel()` so you don't have to reference the allocator every time
- `idalloc`: a wrapper around `allocator:allocateRiftId()` so you don't have to reference the allocator every time

```Lua
allocator:finalize()
```
Actually places all objects when the `immediate` setting is off/false, errors otherwise.

```Lua
mask = allocator:getObjectMask()
```
- `mask`: (a reference to) the Bitplane masking where the allocator can place objects

Set a position to `false` to block it off from the allocator. All spaces default to `true`.

```Lua
cmask = allocator:getChannelMask()
idmask = allocator:getRiftIdMask()
```
- `cmask`: (a reference to) the table masking which channels can be used by the allocator.
- `idmask`: (a reference to) the table masking which rift IDs can be used by the allocator.

Channels/Rift IDs are the keys in the tables.
Set one to `false` to block it off from the allocator. The tables default to all `true`.

```Lua
allocator:setTopLeftCorner(x, y)
```
- `x, y`: the position of the top-left corner (inclusive)

Sets the top-left corner of the area in which things can be allocated.
Use together with the `size` setting to limit the allocator to a specific area.
