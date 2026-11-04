class_name Healthbar
extends Node2D
## A row of knight heads in the HUD, one per life. Lost lives turn black.
## The "Life" child is a template that gets duplicated [member max_lives] times.

@export var max_lives: int = 3
@export var spacing: float = 2.0
@export var life_scale: float = 2.0

var _current_lives: int = 0
var _lives: Array[Sprite2D] = []

@onready var _template: Sprite2D = $Life


func _ready() -> void:
	Events.lives_changed.connect(_on_lives_changed)
	_template.visible = false
	_template.scale = Vector2.ONE * life_scale
	var step := _template.region_rect.size.x * life_scale + spacing

	for i in max_lives:
		var life := _template.duplicate() as Sprite2D
		life.position = _template.position + Vector2(i * step, 0)
		add_child(life)
		_lives.append(life)

	set_lives(max_lives)


func _exit_tree() -> void:
	Events.lives_changed.disconnect(_on_lives_changed)


func _on_lives_changed(lives: int) -> void:
	set_lives(lives)


func set_lives(count: int) -> void:
	_current_lives = clampi(count, 0, max_lives)
	for i in _lives.size():
		_lives[i].visible = true
		_lives[i].modulate = Color.WHITE if i < _current_lives else Color.BLACK
