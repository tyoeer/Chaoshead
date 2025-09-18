# Chaoshead

A level editor, scripting interface, campaign editor, and reverse engineering tool for [Levelhead](https://lvlhd.co),
made using [LÖVE](http://www.love2d.org).

[For installation and basic usage instructions, see further down this README.](#installation)

If you have any questions, feel free to ask.

Chaoshead Update Awareness Day is annually on february 27, in order to spread awareness about Chaoshead updates.

Chaoshead tries to impose as little limits as possible.
[For more information about those limits and which you're allowed to break, go here.](http://levelmod.epizy.com/wiki/doku.php?id=blocked_stuff)

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
		- [See documentation in the scripts folder](docs/index.md)
	- Built-in scripts (see [further down this readme](#built-in-scripts))
		- E.g. Excel-like auto-fill
- A palette to select objects from to place
- Verification that the saved level is a valid level file before irrevocably removing the old level file

### Maintenance status

Chaoshead is feature-complete enough to already be very useful when the Levelhead editor isn't enough.
However, there's practically no active development of features anymore, even though there is always more neat stuff that can be added.
Though if someone runs into a bug or has a very highly requested feature I'll try to fix/add that.
I also still watch this repository and can be found in the BScotch Discord, so if there're any question please reach out to me.

### Installation

#### Windows

- Download the latest version from https://github.com/tyoeer/Chaoshead/releases/latest/download/chaoshead-win32.zip
	- This just the `chaoshead-win32.zip` file from the latest release on [the releases page](https://github.com/tyoeer/Chaoshead/releases/)
- Unzip it in a folder somewhere, and run `Chaoshead.exe`

Basic usage:
- Keybinds can be viewed in the Misc. tab
- For actual graphics that aren't colored shapes:
	- Get Levelhead to export its images by pressing "Export game data" in the "Data & safety" settings
	- Then press F10 in Chaoshead
	- You might have to restart Chaoshead so it properly detects the images

#### Linux

1. Currently, you have to install [LÖVE](https://love2d.org) yourself (installation instructions are on their website).
	- You can also try grabbing LÖVE from your package manager, but do note that the Debian package has a longstanding bug (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1025649) that makes it break Chaoshead.
2. After you have obtained LÖVE, you have to download/clone the Chaoshead source code
3. To run Chaoshead, run `love path/to/Chaoshead/src` in a terminal, or just `love src` in the Chaoshead directory

Chaoshead will try to automatically find the folders where Levelhead stores user data and where the Levelhead .exe is located,
but might fail and crash when it runs into issues [(tracked here)](https://github.com/tyoeer/Chaoshead/issues/162).
In that case, you'll have to manually specify the paths in the settings. \
The settings can be found in `$XDG_DATA_HOME/love/chaoshead/` or `~/.local/share/love/chaoshead/`.
The file you want is `/settings/misc.json`.
The settings are:
- `levelheadDataPath`: this should point at the `PlatformerBuilder` folder
- `levelheadInstallationPath`: this should point at the folder containing `Levelhead.exe`, but will only crash when left empty when doing stuff with the campaign.

If your path is from a somewhat standard installation, do let me know and I'll add them to the paths Chaoshead checks automatically.


Basic usage is the same as for Windows.

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
