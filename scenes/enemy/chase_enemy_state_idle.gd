class_name ChaseEnemyStateIdle
extends State


func enter() -> void:
	owner.speed = 0.0
	owner.sprite.play("idle")


func physics_update(_delta: float) -> void:
	var distance_to_player: float = owner.player.position.distance_to(owner.position)
	if distance_to_player < owner.chase_distance:
		owner.machine.transition_to(ChaseEnemyStateChase.new())
