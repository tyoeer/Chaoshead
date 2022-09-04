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

- `levelhead/`: All the code for integrating with Levelhead stuff
  - `data/`: Wrappers around the data files.
  - `lhs/`: All the code directly dealing with a `.lhs` file.
  - `level/`: Everything dealing with the Lua representation of a LH level.
    - `limits.lua`: A list of functions for checking various limits imposed by several different things.
- `ui/`: The main UI system, and UI parts that aren't their own module. Has its own design.md describing (some of) the design of the UI system.
- `settings/`: The settings & storage systems.
  - `init.lua`: The actual code. The other files are default settings.

## Misc code

- `script/`: The scripting system. Probably shouldn't be its own folder in its current state.
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
