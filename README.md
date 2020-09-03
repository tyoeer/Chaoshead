# Chaoshead

A WIP scripting interface/reverse engineering tool/level editor for [Levelhead](lvlhd.co) levels/stages, made using [Löve2d](http://www.love2d.org).

As Chaoshead is still in development it is recommended to backup all your levels before using it
(though so far it has only irrevocably corrupted the level it was interacting with,
so perhaps only backupping the specific level you're working on is enough).

If you have any questions, feel free to ask.

### Currently supported
- All publicly available 1.0 foreground objects and structures
- All publicly available 1.0 object properties except Sign icons and Boombox percussion notes

Unsupported content like paths, background stuff, and stuff inside objects will get discarded.

## Terminology

- World: the part of a level that contains all the level (world = level - metadata).
- Object: a single thing inside the level.
- (Level) element: a type of object e.g. Blasters, Armor Plates.
- Item: Something GR-18 can grab and carry.
- Mapping vs. Value (in the context of properties): a value is the raw number saved in the file, a mapping is what that number means.
  E.g. value 1 for rotation is mapping/mapped to "Up".

## Scripting

Chasohead executes from the scripts folder, which can be opened from the Misc. tab.
When it says running scripts without sandbox is dangerous, it mostly means that you shouldn't randomly trust script from others,
making a script yourself will most likely be alright.
Scripts get provided access to the level trough `level` global.
For documentation on how to use the `level` global and other stuff, have a look at the [docs](docs/) folder.

## Useful links

WIP file specification:<br>
https://docs.google.com/document/d/1_Nt0u3DpgLA2KHgwVdcCnMYaY6nGjZcjbRyx1hHp9rA/<br>
Levelhead data (level elements, properties, etc.):<br>
https://docs.google.com/spreadsheets/d/1bzASSn2FgjqUldPzX8DS66Lv-r2lk3V12jZjl51uaTk/<br>
The Trello/todo-list for this project:<br>
https://trello.com/b/eqxuD1A4/chaoshead

## Contributing is easy

There's always data that needs collecting, which just involves editing some stuff in Levelhead,
and looking at it in Chaoshead to get the internal ID's and stuff.
There's also still parts that need to be reverse engineered in which case the Hex Inpector is your friend.
Though if you want to help program this thing, that's also possible.

In any case, try looking at the Trello (linked above) for the tings that still need to be done.

## License

Chaoshead itself is licensed under the Apache 2.0 license (see LICENSE.txt)<br>
Copyright 2020 tyoeer and the Chaoshead contributors<br>
Chaoshead uses some libraries and resources from others, see credits.txt for their authors and licenses.<br>
