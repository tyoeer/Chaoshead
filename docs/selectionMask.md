# SelectionMask

Represents an area selected in a level.
Keeps track of which tiles and which layers are selected.
See the scripting documentation (in the README) for how to access the existing __SelectionMask__ when in a script
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
__EntityPool__ containing all the selected tiles as tables with `x` and `y`.

```Lua
mask.nTiles
```
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
