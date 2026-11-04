class_name MainMenu
extends CanvasLayer
## The first screen: title, credits and one button per level. This is the
## project's main scene. Regular Buttons work with mouse, keyboard and touch
## alike, so the menu needs no special handling for the iPad.

const EASY_LEVEL := "res://scenes/levels/easy/game.tscn"
const MEDIUM_LEVEL := "res://scenes/levels/medium/game.tscn"

var _blink_tween: Tween
var _fade_out := false

@onready var _select_label: Label = %SelectLabel


func _on_blink_timer_timeout() -> void:
	_fade_out = not _fade_out
	if _blink_tween != null:
		_blink_tween.kill()
	_blink_tween = create_tween()
	_blink_tween.tween_property(_select_label, "modulate:a", 0.0 if _fade_out else 1.0, 0.4) \
		.set_trans(Tween.TRANS_SINE)


func _on_easy_button_pressed() -> void:
	get_tree().change_scene_to_file(EASY_LEVEL)


func _on_medium_button_pressed() -> void:
	get_tree().change_scene_to_file(MEDIUM_LEVEL)
