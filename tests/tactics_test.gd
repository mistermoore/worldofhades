extends SceneTree
const Combat = preload("res://scripts/combat.gd")
var checks := 0
var failures := 0
func check(ok: bool, description: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: "+description)
func rewarded(id: String):
	var s = Combat.new()
	for e in s.enemies: e.hp = 0
	s.step(0.01,Vector2.ZERO)
	s.choose_reward(id)
	s.auto_target = -1
	for e in s.enemies: e.active_at = 999
	return s
func _initialize():
	var s = Combat.new()
	s.auto_target = -1
	s.enemies[1].hp = 0
	s.enemies[2].hp = 0
	s.enemies[0].timer = 999
	s.player = s.enemies[0].pos+Vector2(0,2)
	for i in range(23): s.step(0.1,Vector2.ZERO)
	check(s.health == 154 and s.stats.basic_damage == 6,"standing still takes modest regular melee damage")
	check(not s.in_danger(s.enemies[0]),"basic hits do not create dodge warnings")
	s = Combat.new()
	s.auto_target = -1
	s.enemies[0].hp = 0
	s.enemies[2].hp = 0
	s.enemies[1].active_at = 0
	s.enemies[1].timer = 999
	for i in range(16): s.step(0.1,Vector2.ZERO)
	check(s.health == 156 and s.stats.basic_damage == 4,"caster basics create light pressure without ground hazards")
	s = Combat.new()
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.enemies[0].cast = 0.1
	s.enemies[0].aim = Vector2(0,1)
	s.step(0.2,Vector2.ZERO)
	check(s.stats.special_damage == 30,"heavy swing is clearly stronger than basic hits")
	s = Combat.new()
	s.enemies[0].cast = 1
	s.enemies[1].active_at = 0
	s.enemies[1].timer = 0
	s.step(0.1,Vector2.ZERO)
	check(s.enemies[1].cast == 0,"only one special is telegraphed at a time")
	s = Combat.new()
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.use_ability("strike")
	s.momentum = 30
	check(s.use_ability("cleave"),"basic attack never locks out a power")
	s.enemies[0].cast = 2
	check(s.use_ability("charge") and s.enemies[0].cast == 0 and s.gcd == 1,"interrupt works immediately during power global cooldown")
	s = rewarded("lightning")
	s.enemies[1].pos = s.enemies[0].pos+Vector2(2,0)
	s.use_ability("lightning")
	check(s.enemies[0].shocked == 5,"lightning primes its target")
	s.use_ability("charge")
	check(s.stats.combos == 1 and s.enemies[0].shocked == 0,"Charge detonates and consumes primer")
	check(s.enemies[1].hp == s.enemies[1].max_hp-24,"tech burst damages nearby enemies")
	s = rewarded("lightning")
	s.use_ability("lightning")
	s.step(5.1,Vector2.ZERO)
	s.use_ability("charge")
	check(s.stats.combos == 0,"expired primer cannot detonate")
	s = rewarded("rend")
	s.player = s.enemies[0].pos+Vector2(0,2)
	s.use_ability("rend")
	s.momentum = 30
	s.gcd = 0
	s.use_ability("cleave")
	check(s.enemies[0].hp == s.enemies[0].max_hp-82 and s.enemies[0].bleed == 0,"Cleave ruptures and consumes bleed for a burst finisher")
	check(s.stats.combos == 1,"rupture counted as a combo")
	s = rewarded("mend")
	s.health = 100
	s.use_ability("mend")
	check(s.guard == 18 and s.guard_time == 6,"healing grants temporary Guard")
	s.take_damage(6,"basic hit")
	check(s.health == 145 and s.guard == 12,"Guard absorbs basic damage")
	s.take_damage(20,"heavy hit",true)
	check(s.health == 137 and s.guard == 0 and s.stats.special_damage == 8,"heavy damage penetrates depleted Guard correctly")
	check(s.stats.absorbed == 18,"absorbed damage counted")
	s = rewarded("mend")
	s.health = 100
	s.use_ability("mend")
	s.step(6.1,Vector2.ZERO)
	check(s.guard == 0,"unused Guard expires")
	var holding = run_bot("hold")
	var tactical = run_bot("interrupt")
	check(holding.outcome == "ENCOUNTER CLEARED" and tactical.outcome == "ENCOUNTER CLEARED","both ground-holding play styles can clear the encounter")
	check(holding.stats.basic_damage > 0 and tactical.stats.basic_damage > 0,"clearing does not require avoiding every basic attack")
	check(tactical.stats.special_damage < holding.stats.special_damage and tactical.health > holding.health,"saving interrupts rewards decisions rather than constant movement")
	for id in Combat.REWARDS:
		var build = run_reward_bot(id)
		check(build.outcome == "RUN COMPLETE","reward build can complete trial: "+id)
		check(build.stats.absorbed > 0 if id == "mend" else build.stats.combos > 0,"reward's tactical hook is usable: "+id)
	print("Tactical checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
func run_bot(style: String):
	var s = Combat.new()
	for i in range(3000):
		if s.outcome != "": break
		if s.enemies[s.target].hp <= 0: s.cycle_target()
		var e = s.enemies[s.target]
		var offset: Vector2 = e.pos-s.player
		if s.cooldowns.charge <= 0 and ((style == "hold" and offset.length()>3) or (style == "interrupt" and e.cast>0)):
			s.use_ability("charge")
		if s.momentum >= 30 and s.cooldowns.cleave <= 0: s.request_ability("cleave")
		s.step(0.05,offset.normalized() if offset.length()>2.6 else Vector2.ZERO)
		s.events.clear()
	print("%s: %.1fs, %.0f HP, %.0f basic / %.0f heavy damage, %d interrupts" % [style,s.elapsed,s.health,s.stats.basic_damage,s.stats.special_damage,s.stats.interrupts])
	return s

func run_reward_bot(id: String):
	var s = rewarded(id)
	s.auto_target = s.target
	for e in s.enemies: e.active_at = {"bruiser":0.0,"caster":10.0,"support":18.0}[e.kind]
	for i in range(4000):
		if s.outcome != "": break
		if s.enemies[s.target].hp <= 0: s.cycle_target()
		var e = s.enemies[s.target]
		var offset: Vector2 = e.pos-s.player
		if s.cooldowns[id] <= 0 and s.momentum >= Combat.ABILITIES[id].cost:
			if id == "mend" and s.health <= 135: s.request_ability(id)
			elif id == "lightning": s.request_ability(id)
			elif id == "rend" and e.bleed <= 0: s.request_ability(id)
		if s.cooldowns.charge <= 0 and (e.cast>0 or e.shocked>0): s.use_ability("charge")
		if s.momentum >= 30 and s.cooldowns.cleave <= 0: s.request_ability("cleave")
		s.step(0.05,offset.normalized() if offset.length()>2.6 else Vector2.ZERO)
		s.events.clear()
	print("%s: %s, %.1fs, %.0f HP, %d combos, %.0f absorbed" % [id,s.outcome,s.elapsed,s.health,s.stats.combos,s.stats.absorbed])
	return s
