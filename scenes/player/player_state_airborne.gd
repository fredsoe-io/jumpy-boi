class_name PlayerStateAirborne
extends State
## In the air (jumping or falling). Landing effects live in the transition to
## [PlayerStateGrounded]: squish tween, and a landing sound + dust on hard impacts.

var _fall_speed: float = 0.0


func enter() -> void:
	owner.sprite.play("jump")


func physics_update(delta: float) -> void:
	owner.apply_gravity(delta)
	owner.apply_horizontal_input()

	if owner.can_jump():
		owner.jump()
		return

	if owner.is_on_floor():
		var impact_speed := _fall_speed
		_squish()
		if impact_speed > absf(owner.jump_velocity) * 1.15:
			owner.land_sound.pitch_scale = randf_range(0.9, 1.1)
			owner.land_sound.play()
			ParticleSpawner.spawn_burst(owner, owner.global_position, Color.WHITE, 6, 50)

		owner.machine.transition_to(PlayerStateGrounded.new())
		return

	_fall_speed = owner.velocity.y


func _squish() -> void:
	owner.sprite.scale = Vector2(1.3, 0.7)
	owner.create_tween() \
		.tween_property(owner.sprite, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_ELASTIC)
