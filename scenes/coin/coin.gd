class_name Coin
extends Area2D

## Emitted with the coin's global position when the player picks it up.
signal collected(coin_global_position: Vector2)

@onready var _pickup_sound: AudioStreamPlayer = $PickupSound


func _on_body_entered(_body: Node2D) -> void:
	collected.emit(global_position)
	_pickup_sound.pitch_scale = randf_range(0.9, 1.1)
	_pickup_sound.play()
	hide()
	set_deferred("monitoring", false)
	await _pickup_sound.finished
	queue_free()
