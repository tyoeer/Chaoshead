# Grid

An infinite 2d grid allowing setting and getting a value in each cell.

It also allows using non-integers as input coordinates/keys, effectively allowing to be used as map for arbitrary pairs of data.
Though that also means you can silently get different cells if you don't round the input coordinates after doing floating point math.

## Creation

```lua
grid = require("utils.grid"):new()
```

## Usage

```lua
grid:set(x,y,value)
grid(x,y,value)
grid[limitedX][y] = value
```
- x, y: the coordinates at which to set the value
- value: the new value at the specified cell
- limitedX: x part of the coordinate that can't be "call", "set", "get", or "data". If you only use integers it will be fine.
 
All three lines are variants that do the same thing, you don't have to execute all three lines together.

```lua
value = grid:get(x,y)
value = grid(x,y)
value = grid[limitedX][y]
```
- x, y: the coordinates from which to get the value
- value: the value at those coords
- limitedX: x part of the coordinate that can't be "call", "set", "get", or "data". If you only use integers it will be fine.

All three lines are variants that do the same thing, you don't have to execute all three lines together.