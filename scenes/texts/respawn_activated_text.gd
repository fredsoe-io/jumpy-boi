class_name RespawnActivatedText
extends Node2D
## A "Checkpoint" label that floats up when a new checkpoint is activated and
## removes itself.


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -16), 1.0)
	tween.tween_callback(queue_free)
