extends SceneTree
## Headless smoke test for the GDScript port.
##
## Run from the project folder (import first so the global class cache exists):
##	 godot --headless --path . --import
##	 godot --headless --path . -s res://tests/smoke_test.gd
##
## Starts on the main menu and taps the Easy button, then plays through the
## level: drives the player with the touch buttons, collects a coin, dies and
## respawns at the checkpoint, activates the second checkpoint, runs out of
## lives (level reload), then collects every coin to reach the win state and
## restarts. Finally loads the medium level once. Exit code 0 = all checks passed.

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const EASY_SCENE := "res://scenes/levels/easy/game.tscn"
const MEDIUM_SCENE := "res://scenes/levels/medium/game.tscn"
const MAX_SECONDS := 90.0
## Real seconds to wait for the kill zone timer (1 s at half speed) plus the respawn.
const DEATH_SECONDS := 3.0

var _failures: Array[String] = []
var _finished := false
var _elapsed := 0.0


func _initialize() -> void:
	_run()


func _process(delta: float) -> bool:
	_elapsed += delta
	if _elapsed > MAX_SECONDS and not _finished:
		push_error("smoke test timed out after %d s" % MAX_SECONDS)
		quit(1)
	return false


func _run() -> void:
	# 0. Main menu: a tap on the Easy button loads the easy level.
	var menu := _load_scene(MENU_SCENE)
	await _physics_frames(5)
	_check(menu is MainMenu, "main menu scene loads")
	_check(not paused, "menu does not pause the tree")
	var easy_button: Button = menu.get_node("Control/VBoxContainer/HBoxContainer/EasyButton")
	var hard_button: Button = menu.get_node("Control/VBoxContainer/HBoxContainer/HardButton")
	_check(hard_button.disabled, "hard button is disabled (no hard level yet)")
	var button_center := easy_button.get_global_rect().get_center()
	_touch(0, button_center, true)
	await _physics_frames(2)
	_touch(0, button_center, false)
	await _physics_frames(5)
	_check(current_scene != menu and is_instance_valid(current_scene), "tapping Easy leaves the menu")
	_check(current_scene.scene_file_path == EASY_SCENE, "the easy level is the current scene (got %s)" % current_scene.scene_file_path)

	# 1. Level start: HUD at 0/N, three lives, spawn checkpoint active, player lands.
	var game := current_scene
	var player: Player = game.get_node("Player")
	var hud: Hud = game.get_node("Hud/HUD")
	var coins: Node = game.get_node("Coins")
	var checkpoints: Node = game.get_node("Checkpoints")
	var total := coins.get_child_count()
	var checkpoint_1: Checkpoint = checkpoints.get_child(0)
	var checkpoint_2: Checkpoint = checkpoints.get_child(1)
	_check(hud.visible, "HUD is visible even though the scene file hides it")
	_check(_hud_text(hud) == "0/%d" % total, "HUD starts at 0/%d (got %s)" % [total, _hud_text(hud)])
	_check(_lit_lives(hud) == 3, "healthbar shows 3 lives (got %d)" % _lit_lives(hud))
	await _physics_frames(90)
	_check(player.is_on_floor(), "player lands on the floor")
	_check(player.machine.current_state is PlayerStateGrounded, "player state is Grounded after landing")
	_check(_light_on(checkpoint_1), "spawn checkpoint is active at the start")
	_check(not _light_on(checkpoint_2), "second checkpoint starts inactive")
	_check(_count_nodes(game, RespawnActivatedText) == 0, "no checkpoint popup for the spawn checkpoint")

	# 2. Touch buttons drive the existing input actions.
	var touch: TouchControls = game.get_node("TouchControls")
	_check(not touch.visible, "touch controls are hidden without a touchscreen")
	touch.visible = true
	await process_frame
	var right_button: TouchScreenButton = touch.get_node("RightButton")
	var jump_button: TouchScreenButton = touch.get_node("JumpButton")
	var x_before := player.global_position.x
	_touch(0, _button_center(right_button), true)
	await _physics_frames(6)
	_check(Input.is_action_pressed("ui_right"), "right button holds ui_right")
	_check(player.velocity.x > 0.0 and player.global_position.x > x_before, "player walks right while the right button is held")
	_touch(0, _button_center(right_button), false)
	await _physics_frames(2)
	_check(not Input.is_action_pressed("ui_right"), "lifting the finger releases ui_right")
	_touch(1, _button_center(jump_button), true)
	await _physics_frames(3)
	_check(player.machine.current_state is PlayerStateAirborne and player.velocity.y < 0.0, "jump button makes the player jump")
	_touch(1, _button_center(jump_button), false)
	touch.visible = false
	await _physics_frames(90)
	_check(player.is_on_floor(), "player lands again after the touch jump")

	# 3. Collect one coin.
	var first_coin: Coin = coins.get_child(0)
	player.global_position = first_coin.global_position
	await _physics_frames(5)
	_check(_hud_text(hud) == "1/%d" % total, "HUD shows 1/%d after a pickup (got %s)" % [total, _hud_text(hud)])
	_check(_count_nodes(game, CollectedText) == 1, "a +1 popup was spawned (got %d)" % _count_nodes(game, CollectedText))

	# 4. First death: slow motion, then a respawn at the active checkpoint (no reload).
	_kill(player)
	await _physics_frames(5)
	_check(player.machine.current_state is PlayerStateDead, "player state is Dead in the kill zone")
	_check(is_equal_approx(Engine.time_scale, 0.5), "time scale drops to 0.5 on death")
	await create_timer(DEATH_SECONDS, true, false, true).timeout
	_check(is_equal_approx(Engine.time_scale, 1.0), "time scale is back to 1.0 after the death")
	_check(current_scene == game, "level was not reloaded: the player respawns instead")
	_check(_lit_lives(hud) == 2, "healthbar shows 2 lives after the first death (got %d)" % _lit_lives(hud))
	_check(not (player.machine.current_state is PlayerStateDead), "player is alive again after the respawn")
	_check(absf(player.global_position.x - checkpoint_1.global_position.x) < 24.0, "player respawned at the spawn checkpoint")
	_check(_hud_text(hud) == "1/%d" % total, "coin count survives a respawn (got %s)" % _hud_text(hud))

	# 5. Reaching the second checkpoint moves the respawn point and shows a popup.
	player.global_position = checkpoint_2.global_position
	await _physics_frames(5)
	_check(_light_on(checkpoint_2), "second checkpoint lights up when reached")
	_check(not _light_on(checkpoint_1), "first checkpoint goes dark again")
	_check(_count_nodes(game, RespawnActivatedText) == 1, "a 'Checkpoint' popup was spawned (got %d)" % _count_nodes(game, RespawnActivatedText))

	# 6. Second death: one life left, respawn at the second checkpoint.
	_kill(player)
	await create_timer(DEATH_SECONDS, true, false, true).timeout
	_check(current_scene == game, "second death still respawns")
	_check(_lit_lives(hud) == 1, "healthbar shows 1 life after the second death (got %d)" % _lit_lives(hud))
	_check(absf(player.global_position.x - checkpoint_2.global_position.x) < 24.0, "player respawned at the second checkpoint")

	# 7. Third death: out of lives, the level reloads.
	_kill(player)
	await create_timer(DEATH_SECONDS, true, false, true).timeout
	_check(is_equal_approx(Engine.time_scale, 1.0), "time scale is back to 1.0 after the reload")
	_check(current_scene != game and is_instance_valid(current_scene), "level reloaded when the last life is lost")
	game = current_scene
	player = game.get_node("Player")
	hud = game.get_node("Hud/HUD")
	coins = game.get_node("Coins")
	await _physics_frames(5)
	_check(_hud_text(hud) == "0/%d" % total, "HUD is back at 0/%d after the reload (got %s)" % [total, _hud_text(hud)])
	_check(_lit_lives(hud) == 3, "healthbar is back at 3 lives after the reload (got %d)" % _lit_lives(hud))

	# 8. Collect every coin -> win state -> jump restarts.
	game.get_node("Enemies").queue_free()
	game.get_node("KillZone").queue_free()
	await _physics_frames(2)
	for coin in coins.get_children():
		player.global_position = (coin as Node2D).global_position
		await _physics_frames(3)
	await _physics_frames(5)
	_check(_hud_text(hud) == "%d/%d" % [total, total], "HUD shows %d/%d after collecting all coins (got %s)" % [total, total, _hud_text(hud)])
	_check(paused, "tree is paused in the win state")
	_check((hud.get_node("WinLabel") as Label).visible, "win label is visible")

	Input.action_press("ui_jump")
	await process_frame
	await process_frame
	Input.action_release("ui_jump")
	await _physics_frames(5)
	_check(not paused, "tree unpaused after restart")
	_check(current_scene != game and is_instance_valid(current_scene), "level reloaded after the win")

	# 9. The medium level loads and wires up too.
	change_scene_to_file(MEDIUM_SCENE)
	await _physics_frames(5)
	_check(current_scene.scene_file_path == MEDIUM_SCENE, "medium level loads")
	var medium_hud: Hud = current_scene.get_node("Hud/HUD")
	var medium_total: int = current_scene.get_node("Coins").get_child_count()
	_check(_hud_text(medium_hud) == "0/%d" % medium_total, "medium HUD starts at 0/%d (got %s)" % [medium_total, _hud_text(medium_hud)])
	_check(current_scene.get_node("Checkpoints").get_child_count() == 3, "medium level has 3 checkpoints")
	_check(current_scene.get_node_or_null("TouchControls") != null, "medium level has the touch controls")

	_finish()


func _load_scene(path: String) -> Node:
	var packed: PackedScene = load(path)
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	return scene


func _physics_frames(n: int) -> void:
	for i in n:
		await physics_frame


## Drops the player far below the kill zone's world boundary.
func _kill(player: Player) -> void:
	player.global_position = Vector2(player.global_position.x, 5000)


## Sends a real touch event through the input pipeline, as a finger on an iPad would.
## [param pos] is in logical (stretched) viewport coordinates. The event itself wants
## window pixels, which differ in headless mode: the window is 64x64 and gets
## stretched to 1152x1152, so the viewport scales every incoming position by 18.
func _touch(index: int, pos: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = root.get_final_transform() * pos
	event.pressed = pressed
	Input.parse_input_event(event)


func _button_center(button: TouchScreenButton) -> Vector2:
	return button.to_global(button.texture_normal.get_size() * 0.5)


func _hud_text(hud: Hud) -> String:
	return (hud.get_node("CollectedLabel") as Label).text


## Number of lit (white) life sprites in the HUD's healthbar; the hidden template does not count.
func _lit_lives(hud: Hud) -> int:
	var count := 0
	for child in hud.get_node("Healthbar").get_children():
		var life := child as Sprite2D
		if life != null and life.visible and life.modulate == Color.WHITE:
			count += 1
	return count


func _light_on(checkpoint: Checkpoint) -> bool:
	return (checkpoint.get_node("PointLight2D") as PointLight2D).visible


func _count_nodes(node: Node, type: Variant) -> int:
	var count := 0
	for child in node.get_children():
		if is_instance_of(child, type):
			count += 1
	return count


func _check(condition: bool, label: String) -> void:
	if condition:
		print("ok	- ", label)
	else:
		print("FAIL - ", label)
		_failures.append(label)


func _finish() -> void:
	_finished = true
	if _failures.is_empty():
		print("smoke test passed")
		quit(0)
	else:
		print("smoke test: %d failure(s)" % _failures.size())
		quit(1)
