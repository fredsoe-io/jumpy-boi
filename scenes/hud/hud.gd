class_name Hud
extends CanvasLayer
## Coin counter, lives (see [Healthbar]) and the win overlay with fireworks.

@export var collected_count: int = 0:
	set(value):
		collected_count = value
		_draw_collected_text()

@export var total_count: int = 0:
	set(value):
		total_count = value
		_draw_collected_text()

@onready var _collected_label: Label = $CollectedLabel
@onready var _win_label: Label = $WinLabel
@onready var _fireworks_timer: Timer = $FireworksTimer
@onready var _color_tint: ColorRect = $ColorTint


func _ready() -> void:
	_win_label.visible = false
	_color_tint.visible = false
	_draw_collected_text()


func _draw_collected_text() -> void:
	# The setters can run before _ready(), when the label is not resolved yet.
	if _collected_label != null:
		_collected_label.text = "%d/%d" % [collected_count, total_count]


func show_win_state() -> void:
	_win_label.visible = true
	_color_tint.visible = true
	_fireworks_timer.start()


func _on_fireworks_timer_timeout() -> void:
	var viewport := get_viewport()
	var size := viewport.get_visible_rect().size
	var screen_pos := Vector2(randf() * size.x, randf() * size.y)
	var world_pos := viewport.get_canvas_transform().affine_inverse() * screen_pos
	ParticleSpawner.spawn_burst(self, world_pos, Color.ORANGE, randi_range(2, 24))
