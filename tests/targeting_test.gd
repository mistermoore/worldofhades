extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool, text: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+text)
func _initialize(): call_deferred("run")
func run():
	var arena = load("res://arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_process(false)
	arena.paused = false
	arena._process(0)
	await physics_frame
	await physics_frame
	var caster = arena.camera.unproject_position(arena.foes[1].position+Vector3.UP)
	print("Caster screen position: ",caster)
	arena.pick_enemy(caster)
	check(arena.sim.target == 1 and arena.sim.auto_target == 1,"click ray selects enemy and arms automatic Strike")
	arena.pick_enemy(Vector2(10,700))
	check(arena.sim.target == 1,"empty ground keeps current target")
	arena.paused = true
	var bruiser = arena.camera.unproject_position(arena.foes[0].position+Vector3.UP)
	arena.pick_enemy(bruiser)
	check(arena.sim.target == 1,"pause blocks click targeting")
	arena.paused = false
	arena.sim.enemies[2].hp = 0
	arena._process(0)
	await physics_frame
	var dead = arena.camera.unproject_position(arena.foes[2].position+Vector3.UP)
	arena.pick_enemy(dead)
	check(arena.sim.target == 1,"dead enemies cannot be selected")
	arena.click_candidate = true
	var right = InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = true
	arena._input(right)
	check(not arena.click_candidate,"right mouse cancels pending selection for steering")
	arena.click_candidate = true
	arena.click_distance = 0
	var motion = InputEventMouseMotion.new()
	motion.relative = Vector2(10,0)
	arena._input(motion)
	check(not arena.click_candidate,"dragging cancels click selection")
	print("Targeting checks: %d passed, %d failed" % [checks-failures,failures])
	arena.queue_free()
	quit(1 if failures else 0)
