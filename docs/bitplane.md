# Bitplane

Represents a 2d fixed-size boolean grid.

## Creation

```Lua
bitplane = require("tools.bitplane").new(width,height[,default])
```
- width, height: the size of the bitplane
- default: the initial value of all the grid-spaces. Defaults to false.


```Lua
bitplane = require("tools.bitplane").newFromStrings(falseMask, trueMask, strings...)
```
- falseMask: a string containing all characters that should be considered to be a false value
- trueMask: a string containing all characters that should be considered to be a true value
- strings... a vararg or table listing all the strings

The the characters in the strings represent the bitplane, starting at (0,0), continue further along the positive x-axis towards the end of the string.
The next string is further along the positive y-axis.
(If (0,0) is the top-left corner, the strings as displayed in the source code match the orientation of the resulting bitplane.)
If a character is in the falseMask, the value in the bitplane at that position is false, and vice-verse for the trueMask.
The falseMask takes precedence over the trueMask, and if a character is in neither mask, it errors.
If the strings don't form a rectangle the behaviour is undefined

```Lua
bitplane = require("tools.bitplane").invert(source)
bitplane = require("tools.bitplane").bnot(source)
```
source: the bitplane to invert

Returns a new bitplane with the same size as source, but with all values inverted (aka the binary not). (Without changed the source bitplane.)

```Lua
bitplane = require("tools.bitplane").bor(sourceA, sourceB)
```
sourceA, sourceB: the bitplanes to create the binary OR of.

Returns a bitplane with the same size as the sources, of which all the values are the binary OR of the sources. (Without changing the source bitplanes.)
Errors if the sources are different sizes.

```Lua
bitplane = require("tools.bitplane").band(sourceA, sourceB)
```
sourceA, sourceB: the bitplanes to create the binary AND of.

Returns a bitplane with the same size as the sources, of which all the values are the binary AND of the sources. (Without changing the source bitplanes.)
Errors if the sources are different sizes.

```Lua
bitplane = require("tools.bitplane").xor(sourceA, sourceB)
bitplane = require("tools.bitplane").bxor(sourceA, sourceB)
```
sourceA, sourceB: the bitplanes to create the binary XOR of.

Returns a bitplane with the same size as the sources, of which all the values are the binary XOR of the sources. (Without changing the source bitplanes.)
Errors if the sources are different sizes.

## The bitplane itself

```Lua
bitplane:set(x,y,value)
```
- x, y: the position of the field to change
- value: the new value of the field

```Lua
bitplane:setRect(x,y, width,height, value)
```
- x, y: the top-left corner of the rectangle
- width, height: the size of the rectangle
- value: what to set it to

Sets all spaces inside the rectangle to `value`

```Lua
value = bitplane:get(x,y)
```
- x, y: the position of the field
- value: the value of the field

```Lua
doesIt = bitplane:rectContains(x,y, width,height, value)
```
- x, y: the top-left corner of the rectangle
- width, height: the size of the rectangle
- value: what to check for

Returns true if the given rectangle contains value, false otherwise.

```Lua
bitplane:iterateFunction(func)
bitplane:forEach(func)
```
- func(x,y,value): the function to iterate over all the fields in the bitplane.
	- x, y: the position of the current field
	- value: the value of the current field
	
Iterates the function over all the fields, first upwards along the x-axis, and after every row up the y-axis.

```Lua
bitplane.width
bitplane.height
```
The read-only width and height of the bitplane.