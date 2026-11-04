class_name Player
extends CharacterBody2D
## The knight. Movement is split into [PlayerStateGrounded], [PlayerStateAirborne]
## and [PlayerStateDead]; this script owns the shared helpers (gravity, input,
## jump, respawn) and the coyote-time / jump-buffer timers.

const COYOTE_TIME := 0.05
const JUMP_BUFFER := 0.10

var speed: float = 150.0
var jump_velocity: float = -300.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var machine: StateMachine

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound


func _ready() -> void:
	machine = StateMachine.new(self, PlayerStateAirborne.new())


func _process(delta: float) -> void:
	machine.update(delta)


func _physics_process(delta: float) -> void:
	coyote_timer = COYOTE_TIME if is_on_floor() else maxf(coyote_timer - delta, 0.0)
	jump_buffer_timer = JUMP_BUFFER if Input.is_action_just_pressed("ui_jump") else maxf(jump_buffer_timer - delta, 0.0)

	machine.physics_update(delta)
	move_and_slide()


func can_jump() -> bool:
	return jump_buffer_timer > 0.0 and coyote_timer > 0.0


func apply_gravity(delta: float) -> void:
	velocity += get_gravity() * delta


## Applies horizontal movement from input and returns the input axis (-1..1).
func apply_horizontal_input() -> float:
	var axis := Input.get_axis("ui_left", "ui_right")
	if axis != 0.0:
		velocity = Vector2(axis * speed, velocity.y)
		sprite.flip_h = axis < 0
	else:
		velocity = Vector2(move_toward(velocity.x, 0, speed), velocity.y)
	return axis


func jump() -> void:
	velocity = Vector2(velocity.x, jump_velocity)
	jump_sound.pitch_scale = randf_range(0.9, 1.1)
	jump_sound.play()
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	machine.transition_to(PlayerStateAirborne.new())


func die() -> void:
	machine.transition_to(PlayerStateDead.new())


## Moves the (dead) player to [param spawn_position] and brings it back to life.
func respawn(spawn_position: Vector2) -> void:
	velocity = Vector2.ZERO
	global_position = spawn_position
	# Let physics register the new position before collision is re-enabled
	# (which happens when the dead state is left).
	await get_tree().physics_frame
	await get_tree().physics_frame
	velocity = Vector2.ZERO
	machine.transition_to(PlayerStateAirborne.new())
