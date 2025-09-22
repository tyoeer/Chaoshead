# SelectionMask

Represents an area selected in a level.
Keeps track of which tiles and which layers are selected.
See the scripting documentation (in the README) for how to access the existing [SelectionMask](selectionMask.md) when in a script
(TL;DR use the `selection.mask` global).

## Creation

```Lua
mask = require("tools.selection.mask"):new()
```

## Tiles

```Lua
mask:add(x,y)
```
- x, y: the position of the tile to add to the selection.

Can handle adding tiles that are already part of the selection.

```Lua
mask:remove(x,y)
```
- x, y: the position of the tile to remove from the selection.

Can handle removing tiles that aren't part of the selection in the first place.

```Lua
present = mask:has(x,y)
```
- present: whether or not the specified tile is in the selection
- x, y: the position of the tile to check.

```Lua
mask.tiles
```
[OrderedSet](orderedSet.md) containing all the selected tiles as tables with `x` and `y`.

```Lua
xMin, yMin, xMax, yMax = mask:getBounds()
```
- xMin, yMin: lowest x/y coordinate of any tile
- xMax, yMax: highest x/y coordinate of any tile

Returns the bounds of all the tiles in the selection.

```Lua
plane, xStart, yStart = mask:getBitplane()
```
- plane: the [Bitplane](bitplane.md) containing tile selection status.
- xStart, yStart: position in the world/level of the Bitplane.

Returns a [Bitplane](bitplane.md) sized to the bounds of the selection, which has true for selected tiles and false for tiles that aren't in this selection.
Bitplane position `1, 1` maps to `xStart, yStart` in the world/level this selection is from.
(This does not actually require a level/world, it's just about their relative frames of reference between the Bitplane and this selection.
Ignore that part if it just causes extra confusion.)

### DEPRECATED

```Lua
mask.nTiles
```
DEPRECATED: use `mask.tiles:size()` instead.
How many tiles are part of this selection.

## Layers

```Lua
mask:setLayerEnabled(layer,enabled)
```
- layer: a string containing a valid layer name (see bottom of this section).
- enabled: boolean specifying whether stuff in this layer is part of the selection or not.

```Lua
enabled = mask:getLayerEnabled(layer)
```
- enabled: boolean specifying whether stuff in this layer is part of the selection or not.
- layer: a string containing a valid layer name (see bottom of this section).

### Layer names

Valid layer names are:
- `foreground`
- `background`
- `pathNodes`
