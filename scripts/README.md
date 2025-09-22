# Chaoshead build script

[Deno](https://deno.com) scripts that:
- Packages Chaoshead with LÖVE into runnable programs for Windows x32 and Linux AppImage
- Attaches misc. files (README, licences, docs)
- Downloads misc. related files

Notes:
- It has no dependencies other than Deno, does not fundamentally require an internet connection.
- It uses command line tools `git`, `zip`, `unzip`, `build/appimagetool.AppImage`.
  It tries to verify those tools beforehand, but is not very thorough/strict.
  It currently assumes Linux, but should not be too hard to update for other OS's.

Run with `deno scripts/run.ts [subcommand]`. It lists available subcommands when you enter a wrong one.

To read a .env use `deno --env-file=../chpt.env scripts/run.ts`