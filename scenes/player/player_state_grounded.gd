class_name PlayerStateGrounded
extends State
## On the floor. Idle vs. run is just an animation choice inside this state.


func enter() -> void:
	owner.sprite.play("idle")


func physics_update(_delta: float) -> void:
	var axis: float = owner.apply_horizontal_input()
	owner.sprite.play("run" if axis != 0.0 else "idle")

	if owner.can_jump():
		owner.jump()
		return

	if not owner.is_on_floor():
		owner.machine.transition_to(PlayerStateAirborne.new())
