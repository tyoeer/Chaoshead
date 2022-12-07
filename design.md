## Modules

Independent pieces with their own goal. Have their own top level tab.

- `levelEditor/`: Module for editing levels and running scripts on them. Tab is called "Workshop".
  - `workshop/`: All the code that doesn't deal with an individual level.
  - `details/`: All the stuff that appears in the left pane of the level editor.
- `dataExplorer/`: Module for investigating/reverse engineering misc. stuff in the `PlatformerBuilder` folder.
  - `viewers/`: The lasses that display the contents of a file in various ways.
- `campaignEditor/`: Module for editing campaigns.
  - `overview/`: All the code that doesn't deal with editing an individual campaign

## Core systems

The stuff on which the rest of CH is built.

- `chaoshead/`: All the top-level/module-independent UI stuff.
- `levelhead/`: All the code for integrating with Levelhead stuff
  - `data/`: Wrappers around the data files.
  - `lhs/`: All the code directly dealing with a `.lhs` file.
    - `read` & `write` convert between the file and a direct representation in Lua
    - `parse` & `serialize` convert between that direct representation and usable representations of actual levels
  - `level/`: Everything dealing with the Lua representation of a LH level.
    - `limits.lua`: A list of functions for checking various limits imposed by several different things.
- `ui/`: The main UI system. Has its own design.md describing (some of) the design of the UI system.
- `settings/`: The settings & storage systems aka systems for data that persists between restarts.
  - `init.lua`: The actual code.
  - The other files: default settings.

## Misc code

- `script/`: The scripting system. Probably shouldn't be its own folder in its current state.
- `exePatch/`: Stuff related to patching the executable.
  - `noCache.md`: Description of how te recreate the patch to disable level caching
  - `noCache.1337`: Actual file saying which bytes to change. File format is from x64dbg.
- `tools/`: Code that should be accessible from user scripts.
- `scripts/`: Built-in scripts. Limited to `/.built-in/` to keep them apart from user scripts.
- `libs/`: Contains external libraries
- `utils/`: Other code that didn't fit anywhere else.

## Resources

- `data/`: Contains `.tsv` data files based on [the spreadsheet](https://docs.google.com/spreadsheets/d/1bzASSn2FgjqUldPzX8DS66Lv-r2lk3V12jZjl51uaTk/)
- `docs/`: Documentation for user scripts.
- `resources/`: Contains non code misc. stuff (font & image used in README)
- `licenses/`: All the licenses of third-party stuff used by Chaoshead. Has a naming scheme for the licenses.
- `.github/`: Contains the release Github Action.
- `https.dll`: HTTPS library, has to be top-level because DLL libraries are weird. This is the 64x bit Windows version, which is included because I think that's what most developers would use. CH will report a nice error modal and where to get a different version if it fails to load when you use a different system.
