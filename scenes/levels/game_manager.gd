class_name GameManager
extends Node
## One per level. Counts collected coins, shows the popups, tracks lives and the
## active checkpoint, and handles death (respawn or reload) and the win state.

const START_LIVES := 3

@export var collected_text_scene: PackedScene
@export var respawn_activated_text_scene: PackedScene

var _score: int = 0
var _lives: int = START_LIVES
var _has_won: bool = false
var _active_checkpoint: Checkpoint

@onready var _hud: Hud = $"../Hud/HUD"
@onready var _coins: Node = $"../Coins"
@onready var _checkpoints: Node = $"../Checkpoints"


func _ready() -> void:
	_score = 0

	_hud.visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	_hud.total_count = _coins.get_child_count()

	Events.player_killed.connect(_on_player_killed)

	for child in _coins.get_children():
		var coin := child as Coin
		if coin != null:
			coin.collected.connect(_on_coin_collected)

	for child in _checkpoints.get_children():
		var checkpoint := child as Checkpoint
		if checkpoint != null:
			checkpoint.checkpoint_reached.connect(_on_checkpoint_entered)

	Events.lives_changed.emit(_lives)


func _exit_tree() -> void:
	Events.player_killed.disconnect(_on_player_killed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_jump") and _has_won:
		get_tree().paused = false
		get_tree().reload_current_scene()


func add_score(points: int = 1) -> void:
	_score += points
	_hud.collected_count = _score


func _on_player_killed(player: Player) -> void:
	if _active_checkpoint != null and _lives > 1:
		_lives -= 1
		Events.lives_changed.emit(_lives)
		player.respawn(_active_checkpoint.global_position)
	else:
		get_tree().reload_current_scene()


func _on_checkpoint_entered(_body: Node2D, checkpoint: Checkpoint) -> void:
	if _active_checkpoint == checkpoint:
		return

	# No popup for the first checkpoint, the one at the spawn point.
	if _active_checkpoint != null:
		var popup: RespawnActivatedText = respawn_activated_text_scene.instantiate()
		popup.global_position = checkpoint.global_position + Vector2(-16, -16)
		get_tree().current_scene.add_child(popup)
		_active_checkpoint.set_active(false)

	_active_checkpoint = checkpoint
	_active_checkpoint.set_active(true)


func _on_coin_collected(coin_position: Vector2) -> void:
	add_score()

	var popup: CollectedText = collected_text_scene.instantiate()
	popup.global_position = coin_position
	get_tree().current_scene.add_child(popup)
	_check_win_condition()


func _check_win_condition() -> void:
	if _score >= _hud.total_count:
		_hud.show_win_state()
		_has_won = true
		get_tree().paused = true
