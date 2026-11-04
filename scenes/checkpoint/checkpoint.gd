class_name Checkpoint
extends Node2D
## A respawn point. Dimmed and unlit until the player touches it; the game
## manager keeps only one checkpoint active at a time.

## Emitted when a body enters the checkpoint area.
signal checkpoint_reached(body: Node2D, checkpoint: Checkpoint)

var _shader_material: ShaderMaterial

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _point_light: PointLight2D = $PointLight2D


func _ready() -> void:
	# Each checkpoint needs its own material, otherwise toggling one would toggle all.
	_shader_material = _sprite.material.duplicate() as ShaderMaterial
	_sprite.material = _shader_material
	set_active(false)


func set_active(active: bool) -> void:
	_shader_material.set_shader_parameter("active", active)
	_point_light.visible = active


func _on_checkpoint_entered(body: Node2D) -> void:
	set_active(true)
	checkpoint_reached.emit(body, self)
