class_name CollectedText
extends Node2D
## A "+1" that floats up from a collected coin and removes itself.


func _ready() -> void:
	ParticleSpawner.spawn_burst(self, global_position, Color("#FFD700"), 8)

	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -16), 1.0)
	tween.tween_callback(queue_free)
