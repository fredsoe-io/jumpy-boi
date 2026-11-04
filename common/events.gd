extends Node
## Game-wide signals. Registered as the [code]Events[/code] autoload in
## project.godot, so any node can emit or connect without knowing who listens:
## the kill zone announces a death, the game manager decides what it means.
## No class_name: the autoload name already makes it a global.

## The player died (kill zone hit, after the slow-motion death animation).
signal player_killed(player: Player)

## The number of remaining lives changed; the healthbar listens.
signal lives_changed(lives: int)
