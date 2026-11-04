class_name ChaseEnemyStateChase
extends State


func enter() -> void:
	owner.speed = owner.chase_speed
	owner.chase_player.play()
	owner.sprite.play("chase")


func exit() -> void:
	owner.chase_player.stop()


func physics_update(_delta: float) -> void:
	if owner.player.position.distance_to(owner.position) > owner.chase_distance * 1.05:
		owner.machine.transition_to(ChaseEnemyStateIdle.new())
