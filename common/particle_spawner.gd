class_name ParticleSpawner
extends RefCounted
## Spawns a one-shot burst of particles in the current scene and frees it afterwards.


static func spawn_burst(context: Node, pos: Vector2, color: Color = Color.WHITE, amount: int = 12, speed: float = 110.0) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.z_index = 10
	p.explosiveness = 0.9 # release them all at once = a pop
	p.amount = amount
	p.spread = 90.0 # ±90° around direction = the upper half
	p.direction = Vector2.UP
	p.gravity = Vector2(0, 250)
	p.scale_amount_min = 2.0
	p.scale_amount_max = 3.0
	p.lifetime = 0.5
	p.color = color
	p.initial_velocity_min = speed
	p.initial_velocity_max = speed

	context.get_tree().current_scene.add_child(p)
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	p.global_position = pos
	p.emitting = true

	context.get_tree().create_timer(1.2).timeout.connect(p.queue_free)
