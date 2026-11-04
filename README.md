# Jumpy Boi

A small 2D platformer we make together as a family. The kids design the levels
and record the sound effects, dad writes the code. Collect every coin without
touching the monsters. Fall off and you respawn at the last checkpoint, with
three lives per level.

**Play it in the browser:** <https://fredsoe.io/platformer> (keyboard, or
on-screen buttons on an iPad or phone).

![The knight at the start of the easy level](docs/screenshot.png)

![The level select screen](docs/menu.png)

## Controls

| Action  | Keyboard                  | Touch screen          |
| ------- | ------------------------- | --------------------- |
| Move    | A / D or Left / Right     | on-screen arrows      |
| Jump    | Space, W or Up            | on-screen jump button |
| Restart | jump, after you have won  | jump button           |

A gamepad d-pad or left stick moves too.

## How it is made

- [Godot 4.7](https://godotengine.org/), written in GDScript.
- The game is first written in C# in a private repo, and every new feature is
  ported 1:1 to GDScript here. Godot cannot export C# projects to the web, and
  the web is where the kids play it.
- The player and the chasing slime run on a tiny state machine
  (`common/state_machine.gd`): the player is Grounded, Airborne or Dead; the
  slime is Idle or Chasing.
- Game-wide events (a death, a change in lives) go through the `Events`
  autoload (`common/events.gd`), so the kill zone, the game manager and the
  healthbar never need to know about each other.
- On a touch screen the level shows three `TouchScreenButton`s
  (`scenes/touch_controls/`) that feed the same input actions the keyboard
  uses, so the player code does not know they exist. The layer hides itself on
  devices without a touch screen.

## Project layout

```
common/          state machine, Events autoload, particle helper
scenes/
  menu/          main menu (the main scene): pick a level
  levels/        game_manager.gd + one folder per level (easy, medium)
  player/        the knight and its three states
  enemy/         patrol slime, chasing slime, jumping slime
  checkpoint/    respawn points with a dim/lit shader
  coin/ hud/ healthbar/ killzone/ platform/ texts/ touch_controls/
sprites/ sounds/ music/ fonts/ themes/ tilemaps/
tests/           headless smoke test and the screenshot script (not exported)
docs/            README images (not imported by the editor)
```

## Run it yourself

Open the folder in the **standard** Godot 4.7 editor (not the .NET build; it
cannot export to the web) and press Play.

### Web export

The `Web` preset in `export_presets.cfg` has thread support turned off, so the
build runs as plain static files, with no cross-origin isolation headers, and
works in Safari on an iPad. Install the web export templates once from
Editor > Manage Export Templates, then:

```bash
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html
python3 -m http.server -d build/web 8000   # browsers refuse wasm from file://
```

Then open <http://localhost:8000>. To try the touch layout on a desktop, turn
on Project Settings > Input Devices > Pointing > Emulate Touch From Mouse and
use the browser's device toolbar with touch enabled.

### Smoke test

A headless play-through that starts on the menu, taps the Easy button, drives
the player with the touch buttons, collects a coin, dies and respawns at a
checkpoint, runs out of lives, and finally wins. It exits non-zero on failure.

```bash
godot --headless --path . --import
godot --headless --path . -s res://tests/smoke_test.gd
```

### Screenshots

`tests/screenshot.gd` re-renders the images in `docs/`. It needs a window:

```bash
godot --path . -s res://tests/screenshot.gd
```

## Credits

- Levels and sound effects (jump, land, coin, death, the slimes): Adam & Lilli.
- Code: Jacob.
- Sprites, music, font and the remaining sounds come from the Brackeys
  platformer asset bundle (CC0). See `LICENSE & CREDITS.txt` for the
  individual artists.
