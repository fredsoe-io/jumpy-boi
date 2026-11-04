class_name KillZone
extends Area2D
## Kills the player on contact: slow-motion death animation, then it announces
## the death on the [code]Events[/code] autoload and lets the game manager decide
## between a respawn and a level reload. Its collision mask only includes the
## player layer, so enemies never trigger it.

var _killed_player: Player

@onready var _timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	_killed_player = player
	player.die()
	Engine.time_scale = 0.5
	player.velocity = Vector2(0, -150)
	_timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	Events.player_killed.emit(_killed_player)
