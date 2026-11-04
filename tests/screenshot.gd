extends SceneTree
## Renders the README screenshots into docs/. Needs a window, so no --headless:
##	 godot --path . -s res://tests/screenshot.gd
##
## Each shot loads a scene, optionally walks the player right for a moment so
## the camera shows more than the spawn point, waits for things to settle, and
## saves the root viewport at 1152x648.

const SIZE := Vector2i(1152, 648)
const SHOTS := [
	{"scene": "res://scenes/menu/main_menu.tscn", "file": "res://docs/menu.png", "walk": 0.0, "settle": 0.4},
	{"scene": "res://scenes/levels/easy/game.tscn", "file": "res://docs/screenshot.png", "walk": 0.6, "settle": 1.4},
]


func _initialize() -> void:
	_run()


func _run() -> void:
	DisplayServer.window_set_size(SIZE)
	await process_frame
	for shot in SHOTS:
		var packed: PackedScene = load(shot.scene)
		var scene: Node = packed.instantiate()
		root.add_child(scene)
		current_scene = scene
		if shot.walk > 0.0:
			await create_timer(0.6).timeout # land first
			Input.action_press("ui_right")
			await create_timer(shot.walk).timeout
			Input.action_release("ui_right")
		await create_timer(shot.settle).timeout
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		# On a HiDPI screen the viewport is rendered at 2x; bring it back to the logical size.
		if image.get_size() != SIZE:
			image.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_NEAREST)
		var err := image.save_png(shot.file)
		print("%s -> %s (%s, %dx%d)" % [shot.scene, shot.file, error_string(err), image.get_width(), image.get_height()])
		scene.queue_free()
		await process_frame
	quit(0)
