# Chaoshead

A WIP scripting interface/reverse engineering tool/level editor for [Levelhead](lvlhd.co) levels/stages,
made using [LÖVE](http://www.love2d.org).

Please don't use Chaoshead for making stuff that would not be theoratically possible to be made in the normal editor
(if it would have just require a lot more work otherwise, it's still ok),
without express approval of the devs.

As Chaoshead is still in development it is recommended to backup all your levels before using it
(though so far it has only irrevocably corrupted the level it was interacting with,
so perhaps only backupping the specific level you're working on is enough).

Binary release that can be run without manually installing LÖVE can be found
[somewhere in that bar on the right](https://github.com/tyoeer/Chaoshead/releases).

If you have any questions, feel free to ask.

Choashead Awareness Day is annually on february 27, in order to spread awareness about Chaoshead updates.

### Currently not supported

- Campaign-only objects and their properties
  - Unsupported properties error upon file load (because the .lhs is can't be loaded)
  - Unsupported objects will only error when placed in a row or column, otherwise they will simply show up with only their internal ID
- Multiple path nodes in the same tile
  - While they do work in Levelhead, the visual bugs show that that isn't intended.
- Saving properties set to NaN
  - Levelhead doesn't even load them
	- I felt like documenting this somewhere, and this was the best place I could think of

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
https://trello.com/b/eqxuD1A4/chaoshead<br>
Collection of update cinematics (when I remember to update it):<br>
http://levelmod.epizy.com/wiki/doku.php?id=cinematics#chaoshead<br>
A very WIP spreadsheet about the campaign levels and their internal data:<br>
https://docs.google.com/spreadsheets/d/1wongis8qvVj3-cHEa4HhmzpL1XkP1TXjWYjV5RobZNw

## Contributing is easy

There's always data that needs collecting, which just involves editing some stuff in Levelhead,
and looking at it in Chaoshead to get the internal ID's and stuff.
There's also still parts that need to be reverse engineered in which case the Hex Inpector is your friend.
Though if you want to help program this thing, that's also possible.

In any case, try looking at the Trello (linked above) for the tings that still need to be done.

### Data collecting tips

\#1D is the hex for the top-right position in a 30 by 30 level.

When CH crashes because of an invalid property save-format, it outputs the hex of the sub-entry.
Just looks how many bytes there are before the first position to see which save-format it is.

## License

Chaoshead itself is licensed under the Apache 2.0 license (see LICENSE.txt)<br>
Copyright 2020 tyoeer and the Chaoshead contributors<br>
Chaoshead uses some libraries and resources from others, see credits.txt for their authors and licenses.<br>
