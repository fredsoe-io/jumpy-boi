class_name State
extends RefCounted
## Base class for one state of a [StateMachine].
##
## [member owner] is the node the machine drives (a [Player], a [ChaseEnemy], ...).
## It is left untyped on purpose: GDScript has no generics, so each concrete
## state knows which owner it belongs to and uses the owner's members directly.
## States switch by calling [code]owner.machine.transition_to(...)[/code]; the
## state does not keep a reference back to its machine, because two RefCounted
## objects pointing at each other would never be freed.

var owner


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass
