class_name StateMachine
extends RefCounted
## Minimal, engine-free state machine. The owning node creates one in
## [code]_ready()[/code] and forwards [code]_process[/code] /
## [code]_physics_process[/code] / [code]_input[/code] to it.

var current_state: State

var _owner


func _init(owner, initial_state: State) -> void:
	_owner = owner
	current_state = initial_state
	current_state.owner = _owner
	current_state.enter()


func transition_to(new_state: State) -> void:
	current_state.exit()
	current_state = new_state
	current_state.owner = _owner
	current_state.enter()


func update(delta: float) -> void:
	current_state.update(delta)


func physics_update(delta: float) -> void:
	current_state.physics_update(delta)


func handle_input(event: InputEvent) -> void:
	current_state.handle_input(event)
