extends SceneTree
const Combat = preload("res://scripts/combat.gd")
var checks := 0
var failures := 0
func check(ok: bool, description: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+description)
func manual_sim():
	var sim = Combat.new()
	sim.auto_target = -1
	return sim
func _initialize():
	var s = manual_sim()
	check(not s.use_ability("strike"),"out of range rejects attack")
	s.player = s.enemies[0].pos+Vector2(0,2)
	check(s.use_ability("strike"),"strike connects")
	check(s.momentum == 15 and s.enemies[0].hp == 282,"strike damages and generates resource")
	check(not s.use_ability("strike"),"global cooldown prevents spam")
	s.step(1.01,Vector2.ZERO)
	check(not s.use_ability("cleave"),"cleave requires resource")
	s.use_ability("strike")
	s.step(1.01,Vector2.ZERO)
	check(s.use_ability("cleave") and s.momentum == 0,"cleave spends resource")
	s = manual_sim()
	s.target = 1
	s.enemies[1].cast = 1.2
	s.player = Vector2(3,4)
	check(s.use_ability("charge"),"charge reaches distant target")
	check(s.enemies[1].cast == 0 and s.player.distance_to(s.enemies[1].pos)<2,"charge interrupts and repositions")
	s = manual_sim()
	s.enemies[1].hp = 0
	s.enemies[2].hp = 0
	s.player = Vector2(0,0)
	s.enemies[0].pos = Vector2(0,-2)
	s.enemies[0].cast = 0.1
	s.enemies[0].aim = Vector2(0,1)
	s.step(0.2,Vector2.ZERO)
	check(s.health == 130,"frontal attack damages inside cone")
	s.enemies[0].cast = 0.1
	s.player = Vector2(0,-4)
	s.step(0.2,Vector2.ZERO)
	check(s.health == 130,"flanking avoids frontal attack")
	s.enemies[0].hp = 1
	check(s.use_ability("strike") and s.outcome == "ENCOUNTER CLEARED","last kill ends encounter")
	var hp = s.health
	s.step(100,Vector2.ONE)
	check(s.health == hp,"completed encounters stop simulation")
	s = manual_sim()
	s.enemies[0].hp = 0
	s.cycle_target()
	check(s.target == 1,"tab skips dead enemies")
	s.health = 1
	s.enemies[1].cast = 0.1
	s.enemies[1].aim = s.player
	s.step(0.2,Vector2.ZERO)
	check(s.outcome == "YOU HAVE FALLEN","lethal damage ends run")
	s = manual_sim()
	for i in range(80): s.step(0.1,Vector2.ZERO)
	check(s.enemies[1].cast == 0 and s.enemies[1].timer == 4,"caster waits through staggered opening")
	s = manual_sim()
	s.enemies[0].hp = 1
	s.health = 100
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.use_ability("strike")
	check(s.health == 108,"defeating an enemy restores health")
	s = manual_sim()
	s.enemies[1].cast = 2
	s.enemies[1].aim = s.player
	check(s.in_danger(s.enemies[1]),"warning detects ground blast danger")
	s.player += Vector2(3,0)
	check(not s.in_danger(s.enemies[1]),"leaving blast removes danger warning")
	s = manual_sim()
	s.step(1,Vector2(0,-1))
	check(s.player == Vector2(0,2),"forward moves five metres per second")
	s = Combat.new()
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.step(0.01,Vector2.ZERO)
	check(s.enemies[0].hp == 282 and s.momentum == 15,"auto Strike damages and builds Momentum")
	s.step(0.4,Vector2.ZERO)
	check(s.enemies[0].hp == 282,"auto Strike respects one-second cadence")
	s.step(0.61,Vector2.ZERO)
	check(s.enemies[0].hp == 264 and s.momentum == 30,"auto Strike repeats after cooldown")
	s.request_ability("cleave")
	check(s.enemies[0].hp == 226 and s.momentum == 0,"automatic Strike does not block manual Cleave")
	s.step(1.01,Vector2.ZERO)
	check(s.enemies[0].hp == 208 and s.momentum == 15,"automatic Strike continues during power cooldown")
	s.cycle_target()
	check(s.auto_target == s.target and s.queued_ability == "","changing target keeps automatic attacks ready and clears pending command")
	s = Combat.new()
	s.step(0.1,Vector2.ZERO)
	check(s.momentum == 0 and s.auto_target == 0,"out-of-range auto waits without moving or spending")
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.step(0.1,Vector2.ZERO)
	check(s.momentum == 15,"auto resumes on entering range")
	s.player = Vector2(13,13)
	s.step(1.1,Vector2.ZERO)
	check(s.momentum == 15 and s.auto_target == 0,"moving out of range suspends automatic attacks")
	s = Combat.new()
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.enemies[0].hp = 1
	s.step(0.01,Vector2.ZERO)
	check(s.auto_target == -1 and s.enemies[1].hp == 200,"target death ends auto without jumping enemies")
	s.step(1.1,Vector2.ZERO)
	check(s.enemies[1].hp == 200,"auto waits after kill until a living target is selected")
	s.cycle_target()
	s.player = s.enemies[s.target].pos+Vector2(0,2)
	s.step(0.01,Vector2.ZERO)
	check(s.enemies[1].hp == 182,"selecting a new target automatically starts Strike")
	print("Combat checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
