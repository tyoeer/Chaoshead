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

## DEPRECATED

### Amounts

```Lua
contents.nForeground
```
DEPRECATED: use `contents.foreground.count` instead
How many foreground objects there are in the selection.

```Lua
contents.nBackground
```
DEPRECATED: use `contents.background.count` instead
How many background objects there are in the selection.

```Lua
contents.nPathNodes
```
DEPRECATED: use `contents.pathNodes.count` instead
How many path nodes there are in the selection.
