# SelectionContents

Represents the objects and path nodes inside a selection.
See the scripting documentation (in the README) for how to access the existing __SelectionMask__ when in a script
(TL;DR use the `selection.contents` global).

## Creation

```Lua
contents = require("tools.selection.contents")
```
You probably don't want to use this method of obtaining: changes to the `selection.contents` global get ignored.
See the scripting documentation in the README for more information.

## Lists

```Lua
contents.foreground
```
An __OrderedSet__ containing all the foreground **Object**s in the selection.

```Lua
contents.background
```
An __OrderedSet__ containing all the background **Object**s in the selection.

```Lua
contents.pathNodes
```
An __OrderedSet__ containing all the background **PathNode**s in the selection.

## Amounts

```Lua
contents.nForeground
```
How many foreground objects there are in the selection.

```Lua
contents.nBackground
```
How many background objects there are in the selection.

```Lua
contents.nPathNodes
```
How many path nodes there are in the selection.
