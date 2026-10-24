extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, description: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+description)
func key(code: Key, pressed: bool):
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func _initialize(): call_deferred("run")
func run():
	var arena = load("res://arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_process(false)
	arena.paused = false
	for enemy in arena.sim.enemies: enemy.active_at = 999
	var start: Vector2 = arena.sim.player
	key(KEY_A,true)
	arena._process(0.05)
	key(KEY_A,false)
	check(arena.yaw > 0,"A turns left")
	check(arena.sim.player == start,"turning does not translate the player")
	key(KEY_D,true)
	arena._process(0.05)
	key(KEY_D,false)
	check(absf(arena.yaw) < 0.001,"D turns right")
	key(KEY_Q,true)
	arena._process(0.05)
	key(KEY_Q,false)
	check(arena.sim.player.x < start.x and is_equal_approx(arena.sim.player.y,start.y),"Q strafes left")
	check(is_equal_approx(arena.hero.rotation.y,0),"strafe preserves facing")
	key(KEY_E,true)
	arena._process(0.05)
	key(KEY_E,false)
	check(arena.sim.player.is_equal_approx(start),"E strafes right")
	key(KEY_W,true)
	arena._process(0.05)
	key(KEY_W,false)
	check(arena.sim.player.y < start.y,"W moves forward")
	key(KEY_S,true)
	arena._process(0.05)
	key(KEY_S,false)
	check(arena.sim.player.is_equal_approx(start),"S moves backward")
	arena.yaw = PI/2
	key(KEY_W,true)
	arena._process(0.05)
	key(KEY_W,false)
	check(arena.sim.player.x < start.x and is_equal_approx(arena.sim.player.y,start.y),"forward follows turned heading")
	arena.paused = true
	var heading: float = arena.yaw
	var stopped: Vector2 = arena.sim.player
	key(KEY_D,true)
	key(KEY_E,true)
	arena._process(0.05)
	key(KEY_D,false)
	key(KEY_E,false)
	check(arena.yaw == heading and arena.sim.player == stopped,"pause blocks turning and movement")
	arena.yaw = 0
	arena._process(0)
	check(arena.camera.position.x > arena.hero.position.x,"camera sits over right shoulder")
	check(arena.camera.position.y-arena.hero.position.y < 5,"camera stays below overhead view")
	print("Movement checks: %d passed, %d failed" % [checks-failures,failures])
	arena.queue_free()
	quit(1 if failures else 0)
