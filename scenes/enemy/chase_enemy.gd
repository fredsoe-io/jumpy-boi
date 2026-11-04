class_name ChaseEnemy
extends CharacterBody2D
## Stands still until the player comes within [member chase_distance], then runs
## at them. Driven by a [StateMachine] with [ChaseEnemyStateIdle] / [ChaseEnemyStateChase].

@export var player: Player
@export var chase_speed: float
@export var chase_distance: float

var machine: StateMachine
var speed: float = 0.0

var _direction := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var chase_player: AudioStreamPlayer2D = $ChaseSound


func _ready() -> void:
	machine = StateMachine.new(self, ChaseEnemyStateIdle.new())


func _process(delta: float) -> void:
	machine.update(delta)


func _physics_process(delta: float) -> void:
	machine.physics_update(delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	_direction.x = signf(player.global_position.x - global_position.x)

	velocity.x = _direction.x * speed
	sprite.flip_h = _direction.x < 0

	move_and_slide()
