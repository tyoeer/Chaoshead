# Bitplane

Represents a 2d fixed-size boolean grid.

## Creation

```Lua
instance = require("tools.bitplane").new(width,height)
```
- width, height: the size of the bitplane

All valued are initially `nil` (which acts a bit like false)

```Lua
instance = require("tools.bitplane").newFromStrings(falseMask, trueMask, strings...)
```
- falseMask: a string containing all characters that should be considered to be a false value
- trueMask: a string containing all characters that should be considered to be a true value
- strings... a vararg or table listing all the strings

The the characters in the strings represent the bitplane, starting at (0,0), continue further along the positive x-axis towards the end of the string.
The next string is further along the positive y-axis.
(If (0,0) is the top-left corner, the strings as displayed in the source code match the orientation of the resulting bitplane.)
If a character is in the falseMask, the value in the bitplane at that position is false, and vice-verse for the trueMask.
The falseMask takes precedence over the trueMask, and if a character is in neither mask, it errors.
If the strings don't form a rectangle the behavior is undefined

```Lua
instance = require("tools.bitplane").invert(source)
instance = require("tools.bitplane").bnot(source)
```
source: the bitplane to invert

Returns a new bitplane with the same size as source, but with all values inverted (aka the binary not). (Without changed the source bitplane.)

```Lua
instance = require("tools.bitplane").bor(sourceA, sourceB)
```
sourceA, sourceB: the bitplanes to create the binary OR of.

Returns a bitplane with the same size as the sources, of which all the values are the binary OR of the sources. (Without changing the source bitplanes.)
Errors if the sources are different sizes.

```Lua
instance = require("tools.bitplane").band(sourceA, sourceB)
```
sourceA, sourceB: the bitplanes to create the binary AND of.

Returns a bitplane with the same size as the sources, of which all the values are the binary AND of the sources. (Without changing the source bitplanes.)
Errors if the sources are different sizes.

```Lua
instance = require("tools.bitplane").xor(sourceA, sourceB)
instance = require("tools.bitplane").bxor(sourceA, sourceB)
```
sourceA, sourceB: the bitplanes to create the binary XOR of.

Returns a bitplane with the same size as the sources, of which all the values are the binary XOR of the sources. (Without changing the source bitplanes.)
Errors if the sources are different sizes.

## The bitplane itself

```Lua
Bitplane:set(x,y,value)
```
- x, y: the position of the field to change
- value: the new value of the field

```Lua
value = Bitplane:get(x,y)
```
- x, y: the position of the field
- value: the value of the field

```Lua
Bitplane:iterateFunction(func)
```
- func(x,y,value): the function to iterate over all the fields in the bitplane.
	- x, y: the position of the current field
	- value: the value of the current field
	
Iterates the function over all the fields, first upwards along the x-axis, and after every row up the y-axis.
