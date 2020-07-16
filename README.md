# Chaoshead
A WIP scripting interface/reverse engineering tool/level editor for [Levelhead](https://www.bscotch.net/games/levelhead/) levels/stages, made using [Löve2d](http://www.love2d.org).

## Terminology
- World: the part of a level that contains all the level (world = level - metadata).
- Object: a single thing inside the level.
- (Level) element: a type of object e.g. Blasters, Armor Plates.
- Item: Something GR-18 can grab and carry.
- Mapping vs. Value (in the context of properties): a value is the raw number saved in the file, a mapping is what that number means.
  E.g. value 1 for rotation is mapped to/mappnig "Up".

## Scripting
Scripts have to be placed in `Appdata/Roaming/LOVE/Chaoshead/Scripts` for Chaoshead to find them.
You might have to currently make the necessary folders yourself (I know, I should fix that).
Scripts get provided access to the level trough `level` global.
For documentation on how to use the `level` global and other stuff, have a look at the [docs/](docs/) folder.

## Useful links
WIP file specification:<br>
https://docs.google.com/document/d/1_Nt0u3DpgLA2KHgwVdcCnMYaY6nGjZcjbRyx1hHp9rA/<br>
Levelhead data (level elements, properties, etc.):<br>
https://docs.google.com/spreadsheets/d/1bzASSn2FgjqUldPzX8DS66Lv-r2lk3V12jZjl51uaTk/<br>
