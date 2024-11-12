# Chaoshead

A level editor, scripting interface, campaign editor, and reverse engineering tool for [Levelhead](https://lvlhd.co) in ongoing development,
made using [LÖVE](http://www.love2d.org).


There's a button that shows all the keybinds in the misc. tab. \
Binary releases that can be run without manually installing LÖVE can be found
[somewhere in that bar on the right](https://github.com/tyoeer/Chaoshead/releases). \
Chaoshead is rather stable these days, and will verify that it saved (mostly) correctly before irrevocably removing the old level.

If you have any questions, feel free to ask.

Chaoshead Update Awareness Day is annually on february 27, in order to spread awareness about Chaoshead updates.

Chaoshead tries to impose as little limits as possible.
[For more information about those limits and which your allowed to break, go here.](http://levelmod.epizy.com/wiki/doku.php?id=blocked_stuff)

### Main Level Editor Features

- Resize at all four corners
- Selection:
	- No limits
	- Supports paths
	- You can select air
	- You can limit your selection to only the layers you want
	- Filter the selection based on properties
	- Filter the selection based on which element an object is (also works with air and paths)
- Edit properties:
	- Supports + - / * (and =)
	- Edits all objects in the selection, not just individual ones
	- Supports everything the selection supports: paths, layer selection
- Copy/cut/paste:
	- Supports everything the selection supports: paths, layer selection, air, etc.
	- Works between levels
- Script support:
	- User defined scripts that let you do everything you want
	- Built-in scripts (see [further down this readme](#built-in-scripts))
		- E.g. Excel-like auto-fill
- A palette to select objects from to place

### Maintenance status

There's practically no active development anymore, though if someone runs into a bug or has a very highly requested feature I'll try to fix/add that.
I also still watch this repository and can be found in the BScotch Discord, so if there're any question please reach out to me.


### Currently not supported

- Setting properties on objects that don't have them
  - I think that making property handling handle both known properties as in the data and unknown ones set at runtime simultaneously is more effort than it's worth
	- Workaround for objects/elements: remove data about which properties the element has, it will fall back on the ones specifically set
- Multiple path nodes in the same tile
	- Partially supported: loads and saves, but editor actions don't fully consider them
	- Both the API and the UX are easier when there's only a single path node per tile
- Saving properties set to NaN (Levelhead doesn't even load them)

### Built-in scripts

Chaoshead comes with some built-in scripts, which are shown in the `.built-in` folder in the scripting interface.
More information about the scripts can be found in comments at the top of their files. Their files can be found in the [scripts/.built-in](scripts/.built-in)

## Terminology

- World: the part of a level that contains all the level (world = level - metadata).
- Object: a single instance of a level element.
- Layer: foreground, background, and paths. Allow things inside worlds to overlap by being on different layers.
- (Level) element: a type of object e.g. Blasters, Armor Plates.
- Item: Something GR-18 can grab and carry.
- Mapping vs. Value (in the context of properties): a value is the raw number saved in the file, a mapping is what that number means.
  E.g. value 1 for rotation is mapping/mapped to "Up".
- Contained object/object contents: Example: A Jem inside a Brittle Rock is that Brittle Rocks contained object/contents.

## Scripting

Chaoshead executes from the scripts folder, which can be opened from the Misc. tab.
When it says running scripts without sandbox is dangerous, it mostly means that you shouldn't randomly trust script from others,
making a script yourself will most likely be alright.

Scripts get provided access to the following globals:
- `level`: The **Level** opened in the editor. You usually want to modify this one (using the provided methods).
  If you overwrite it with a new value though, Chaoshead will use that one.
- `selection`: The selection in the current editor, `nil` if nothing is selected. Has the following fields:
  - `mask`: The **SelectionMask** that shows which area of the level is selected.
    If you overwrite it with a new value, Chaoshead will use that one (modifying an existing one is probably easier though).
    If the `selection` global is not set at first, you can set it to a table yourself and then set the `mask` field to a new **SelectionMask**.
  - `contents`: The **SelectionContents** that have all the objects in the current selection.
    Does not update if you change the level or the mask.
    Modifications and overwriting get ignored (the new contents get constructed based on the new mask).

For documentation on how to use these globals and other stuff, have a look at the [docs/](docs/) folder.

## Useful links

WIP file specification:<br>
https://docs.google.com/document/d/1_Nt0u3DpgLA2KHgwVdcCnMYaY6nGjZcjbRyx1hHp9rA/<br>
Levelhead data (level elements, properties, etc.):<br>
https://docs.google.com/spreadsheets/d/1bzASSn2FgjqUldPzX8DS66Lv-r2lk3V12jZjl51uaTk/<br>
The old Trello/todo-list for this project, should probably be deleted since GitHub issues are used now:<br>
https://trello.com/b/eqxuD1A4/chaoshead<br>
Collection of update cinematics (when I remember to update it):<br>
http://levelmod.epizy.com/wiki/doku.php?id=cinematics#chaoshead<br>
A very WIP spreadsheet about the campaign levels and their internal data:<br>
https://docs.google.com/spreadsheets/d/1wongis8qvVj3-cHEa4HhmzpL1XkP1TXjWYjV5RobZNw

## Contributing is easy

There's always data that needs collecting, usually about how something behaves in Levelhead.
If you need to look at the raw representation in the file, you can enable the `misc.editor.showRawNumbers` setting so they will be displayed in Chaoshead.
There's also still parts that need to be reverse engineered in which case the Hex Inspector is your friend.
You can look at [the issues with the reverse engineering label](https://github.com/tyoeer/Chaoshead/labels/reverse%20engineering)
for the more interesting/useful things. Data collection stuff also has that label.

Though if you want to help program this thing, that's also possible.

A basic overview of the code architecture/what goes where can be found in [design.md](design.md)

### Data collecting tips

\#1D is the hexadecimal value for the top-right position in a 30 by 30 level.

When CH crashes because of an invalid property save-format, it prints the bytes (in hexadecimal) of the sub-entry to the console.
Just looks how many bytes there are before the first position to see which save-format it is.

### Type annotations

Works towards adding type annotations as used by [sumneko's language server (and VSCode extension)](https://github.com/sumneko/lua-language-server) is tracked in [issue 85](https://github.com/tyoeer/Chaoshead/issues/85).

### Debugging

Chaoshead has some integration with the [Local Lua Debugger VSCode extension](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode), automatically hooking into it if it's active. The following launch configuration works:
```json
{
	"type": "lua-local",
	"request": "launch",
	"name": "Run",
	"program": {
		"command": "love",
	},
	"args": [
		".",
	],
},
```
With the local lua interpreter set to `love`, and the `love` binary available in the PATH.

## License

Chaoshead itself is licensed under the Apache 2.0 license (see LICENSE.txt)<br>
Copyright 2020 tyoeer and the Chaoshead contributors<br>
Chaoshead uses some libraries and resources from others, see credits.txt for their authors and licenses.<br>
