extends Node
## The in-level hint labels. Swaps the keyboard hint for a touch one on
## touchscreen devices, where the on-screen buttons replace WASD.

@onready var _move_hint: Label = $Label


func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		_move_hint.text = "Use the arrows to move"
