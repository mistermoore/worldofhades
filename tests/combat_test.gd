extends SceneTree
const Combat = preload("res://scripts/combat.gd")
var checks := 0
var failures := 0
func check(ok: bool, description: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+description)
func _initialize():
	var s = Combat.new()
	check(not s.use_ability("strike"),"out of range rejects attack")
	s.player = s.enemies[0].pos+Vector2(0,2)
	check(s.use_ability("strike"),"strike connects")
	check(s.momentum == 15 and s.enemies[0].hp == 132,"strike damages and generates resource")
	check(not s.use_ability("strike"),"global cooldown prevents spam")
	s.step(1.01,Vector2.ZERO)
	check(not s.use_ability("cleave"),"cleave requires resource")
	s.use_ability("strike")
	s.step(1.01,Vector2.ZERO)
	check(s.use_ability("cleave") and s.momentum == 0,"cleave spends resource")
	s = Combat.new()
	s.target = 1
	s.enemies[1].cast = 1.2
	s.player = Vector2(3,4)
	check(s.use_ability("charge"),"charge reaches distant target")
	check(s.enemies[1].cast == 0 and s.player.distance_to(s.enemies[1].pos)<2,"charge interrupts and repositions")
	s = Combat.new()
	s.enemies[1].hp = 0
	s.enemies[2].hp = 0
	s.player = Vector2(0,0)
	s.enemies[0].pos = Vector2(0,-2)
	s.enemies[0].cast = 0.1
	s.enemies[0].aim = Vector2(0,1)
	s.step(0.2,Vector2.ZERO)
	check(s.health == 144,"frontal attack damages inside cone")
	s.enemies[0].cast = 0.1
	s.player = Vector2(0,-4)
	s.step(0.2,Vector2.ZERO)
	check(s.health == 144,"flanking avoids frontal attack")
	s.enemies[0].hp = 1
	check(s.use_ability("strike") and s.outcome == "ENCOUNTER CLEARED","last kill ends encounter")
	var hp = s.health
	s.step(100,Vector2.ONE)
	check(s.health == hp,"completed encounters stop simulation")
	s = Combat.new()
	s.enemies[0].hp = 0
	s.cycle_target()
	check(s.target == 1,"tab skips dead enemies")
	s.health = 1
	s.enemies[1].cast = 0.1
	s.enemies[1].aim = s.player
	s.step(0.2,Vector2.ZERO)
	check(s.outcome == "YOU HAVE FALLEN","lethal damage ends run")
	s = Combat.new()
	for i in range(80): s.step(0.1,Vector2.ZERO)
	check(s.enemies[1].cast == 0 and s.enemies[1].timer == 3,"caster waits through staggered opening")
	s = Combat.new()
	s.enemies[0].hp = 1
	s.health = 100
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.use_ability("strike")
	check(s.health == 120,"defeating an enemy restores health")
	s = Combat.new()
	s.enemies[1].cast = 2
	s.enemies[1].aim = s.player
	check(s.in_danger(s.enemies[1]),"warning detects ground blast danger")
	s.player += Vector2(3,0)
	check(not s.in_danger(s.enemies[1]),"leaving blast removes danger warning")
	s = Combat.new()
	s.step(1,Vector2(0,-1))
	check(s.player == Vector2(0,2),"forward moves five metres per second")
	print("Combat checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
