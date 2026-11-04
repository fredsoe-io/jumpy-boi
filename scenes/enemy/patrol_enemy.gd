class_name PatrolEnemy
extends Node2D
## Walks back and forth; the two raycasts flip the direction at walls.

var speed: int = 60
var direction: int = 1

@onready var _ray_cast_right: RayCast2D = $RaycastRight
@onready var _ray_cast_left: RayCast2D = $RaycastLeft
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	position += Vector2(speed * delta * direction, 0)
	if _ray_cast_right.is_colliding():
		direction = -1
		_sprite.flip_h = true
	elif _ray_cast_left.is_colliding():
		direction = 1
		_sprite.flip_h = false
