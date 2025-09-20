# Scripting

Chaoshead lists scripts to execute from the scripts folder, which can be opened from the Misc. tab within Chaoshead, and defaults to `AppData/Roaming/chaoshead/scripts/`.

When it says running scripts without sandbox is dangerous, it means that scripts have full though inconvenient access to your full computer, with the associated security risks.
That mostly means that you shouldn't randomly trust script from mysterious others,
though making a script yourself will most certainly be alright.

## Interface / Script access

Scripts get provided access to the following globals:
- `level`: The **Level** opened in the editor. \
  You usually want to modify this one (using the provided methods).
  If you overwrite it with a new value though, Chaoshead will use that one.
- `selection`: The selection in the current editor, `nil` if nothing is selected. Has the following fields:
  - `mask`: The **SelectionMask** that shows which area of the level is selected. \
	If you overwrite it with a new value, Chaoshead will use that one (modifying an existing one is probably easier though).
	If the `selection` global is not set at first, you can set it to a table yourself and then set the `mask` field to a new **SelectionMask**.
  - `contents`: The **SelectionContents** that have all the objects in the current selection. \
	Does not update if you change the level or the mask.
	Modifications and overwriting get ignored (the new contents get constructed based on the new mask).
- `ScriptUi`: Tools the show things to the user
	- `requestString(message)`: Displays `message` to the user, with a textbox. Returns the entered text when the user clicks "Confirm".

## Description

IF you start your script with a block comment (`--[[`), Chaoshead will display the contents of that block comment in the Script Interface UI when said script is selected.

## List of pages:

- [Allocator](allocator.md)
- [Bitplane](bitplane.md)
- [Grid](grid.md)
- [Level](level.md)
- [Object](object.md)
- [Ordered Set](orderedSet.md)
- [Path](path.md)
- [SelectionContents](selectionContents.md)
- [SelectionMask](selectionMask.md)
- [Settings](settings.md)