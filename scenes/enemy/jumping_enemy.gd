class_name JumpingEnemy
extends CharacterBody2D
## Jumps on a timer. [member hue_shift] recolours the sprite through a shader so
## one scene gives several colours.

const JUMP_VELOCITY := -400.0

@export_range(-1.0, 1.0, 0.01) var hue_shift: float = 0.0

@onready var _jump_timer: Timer = $JumpTimer
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _jump_player: AudioStreamPlayer2D = $JumpPlayer


func _ready() -> void:
	var material := _animated_sprite.material as ShaderMaterial
	material.set_shader_parameter("hue_shift", hue_shift)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# is_on_floor() is still true on the takeoff frame, so skip it while rising.
	if is_on_floor() and _jump_timer.is_stopped() and velocity.y >= 0:
		_jump_timer.start()
		_animated_sprite.play("ground")

	move_and_slide()


func _on_jump_timer_timeout() -> void:
	_animated_sprite.play("air")
	_jump_player.play()
	velocity.y = JUMP_VELOCITY
