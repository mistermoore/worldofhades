extends SceneTree
const Combat = preload("res://scripts/combat.gd")
var checks := 0
var failures := 0
func check(ok: bool, description: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+description)
func win(sim):
	for enemy in sim.enemies: sim.damage_enemy(enemy,999)
	sim.step(0.01,Vector2.ZERO)
func _initialize(): call_deferred("run")
func run():
	var s = Combat.new()
	check(not s.choose_reward("mend"),"rewards cannot be selected before victory")
	check(not s.use_ability("lightning"),"reward abilities are locked initially")
	win(s)
	check(s.outcome == "ENCOUNTER CLEARED","victory opens rewards")
	check(not s.choose_reward("unknown"),"unknown reward rejected")
	check(s.choose_reward("mend") and s.encounter == 2,"reward starts second encounter")
	check(s.enemies[0].max_hp == 187.5 and s.momentum == 30,"second encounter scales health and grants starting Momentum")
	check(not s.choose_reward("lightning"),"only one reward can be chosen")
	s.health = 100
	check(s.use_ability("mend") and s.health == 145 and s.momentum == 10,"self heal restores health and spends Momentum")
	check(not s.use_ability("mend"),"self heal respects cooldown")
	s.gcd = 0
	s.cooldowns.mend = 0
	s.health = 160
	s.momentum = 100
	check(not s.use_ability("mend") and s.momentum == 100,"full-health heal does not spend resources")
	check(not s.use_ability("rend"),"unchosen reward remains locked")
	s = Combat.new()
	win(s)
	s.choose_reward("lightning")
	s.target = 1
	var hp: float = s.enemies[1].hp
	check(s.use_ability("lightning") and s.enemies[1].hp == hp-45,"lightning damages a distant target")
	check(s.momentum == 5 and s.cooldowns.lightning == 6,"lightning cost and cooldown applied")
	s.gcd = 0
	s.cooldowns.lightning = 0
	s.momentum = 100
	s.player = Vector2(13,13)
	check(not s.use_ability("lightning"),"lightning enforces maximum range")
	s = Combat.new()
	win(s)
	s.choose_reward("rend")
	s.player = s.enemies[0].pos+Vector2(0,2)
	hp = s.enemies[0].hp
	check(s.use_ability("rend") and s.enemies[0].hp == hp-18,"rend applies initial physical damage")
	for enemy in s.enemies: enemy.active_at = 999
	for i in range(50): s.step(0.1,Vector2.ZERO)
	check(is_equal_approx(s.enemies[0].hp,hp-48),"bleed deals 30 damage over five seconds")
	var after_bleed: float = s.enemies[0].hp
	s.step(1,Vector2.ZERO)
	check(s.enemies[0].hp == after_bleed,"expired bleed stops damaging")
	s.enemies[1].hp = 0
	s.enemies[2].hp = 0
	s.enemies[0].hp = 20
	s.momentum = 100
	s.cooldowns.rend = 0
	s.use_ability("rend")
	s.step(1.01,Vector2.ZERO)
	check(s.outcome == "RUN COMPLETE","bleed kill finishes final encounter")
	s = Combat.new()
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.enemies[0].cast = 2
	s.use_ability("charge")
	check(s.enemies[0].vulnerable == 3 and s.enemies[0].cast == 0,"interrupt opens vulnerability window")
	hp = s.enemies[0].hp
	s.gcd = 0
	s.use_ability("strike")
	check(s.enemies[0].hp == hp-22.5,"vulnerability increases damage 25 percent")
	for id in Combat.REWARDS:
		var arena = load("res://arena.tscn").instantiate()
		root.add_child(arena)
		arena.set_process(false)
		arena.paused = false
		win(arena.sim)
		arena._process(0)
		check(arena.reward_panel.visible,"reward UI visible after victory: "+id)
		var choices = arena.reward_panel.get_child(0).get_child(1)
		var index: int = Combat.REWARDS.keys().find(id)
		choices.get_child(index).pressed.emit()
		arena._process(0)
		check(arena.sim.reward == id and arena.intro.visible and not arena.reward_panel.visible,"reward button unlocks chosen ability and readies encounter: "+id)
		arena.toggle_pause()
		arena.sim.health = 100
		arena.sim.player = arena.sim.enemies[0].pos+Vector2(0,2)
		arena.buttons[3].pressed.emit()
		arena._process(0.01)
		check(arena.buttons[3].visible and arena.sim.cooldowns[id] > 0,"slot four activates reward: "+id)
		check(arena.reward_bar.position.x >= 0 and arena.reward_bar.position.x+arena.reward_bar.size.x <= arena.get_viewport().get_visible_rect().size.x,"four-slot bar stays on screen: "+id)
		arena.reset()
		check(arena.sim.reward == "" and arena.sim.encounter == 1,"restart resets reward: "+id)
		arena.queue_free()
	print("Reward checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
