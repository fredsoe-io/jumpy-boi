class_name PlayerStateDead
extends State
## Dead: play the animation and sound, stop horizontal movement, keep falling.
## Collision is switched off so the body drops through the level, and switched
## back on when the state is left (a respawn).


func enter() -> void:
	owner.sprite.play("die")
	owner.death_sound.play()
	var velocity: Vector2 = owner.velocity
	owner.velocity = Vector2(0, velocity.y)
	# Deferred because die() can be called from a physics callback.
	owner.collision_shape.set_deferred("disabled", true)


func exit() -> void:
	owner.collision_shape.set_deferred("disabled", false)


func physics_update(delta: float) -> void:
	owner.apply_gravity(delta)
