extends RefCounted
## Rendering-independent simulation. Inputs are commands; presentation reads state.
const ABILITIES = {
	"strike": {"range": 2.8, "cost": 0, "cooldown": 0.0, "damage": 18.0},
	"cleave": {"range": 3.8, "cost": 30, "cooldown": 4.0, "damage": 38.0},
	"charge": {"range": 13.0, "cost": 0, "cooldown": 8.0, "damage": 12.0},
	"mend": {"range": 0.0, "cost": 20, "cooldown": 8.0, "damage": 0.0},
	"lightning": {"range": 14.0, "cost": 25, "cooldown": 6.0, "damage": 45.0},
	"rend": {"range": 3.0, "cost": 20, "cooldown": 5.0, "damage": 18.0}
}
const REWARDS = {
	"mend": {"name":"Second Wind", "description":"Heal 45 + 18 Guard for 6s.\n20 Momentum / 8s cooldown\nHold ground through basic hits."},
	"lightning": {"name":"Lightning Bolt", "description":"45 damage at 14m. Primes 5s.\n25 Momentum / 6s cooldown\nCharge/Cleave: area tech burst."},
	"rend": {"name":"Rending Slash", "description":"18 damage + 30 bleed over 5s.\n20 Momentum / 5s cooldown\nCleave ruptures bleed for 26."}
}
var encounter := 1
var reward := ""
var player := Vector2(0, 7)
var facing := Vector2(0, -1)
var health := 160.0
var guard := 0.0
var guard_time := 0.0
var stats := {"basic_damage":0.0,"special_damage":0.0,"interrupts":0,"combos":0,"absorbed":0.0}
var momentum := 0.0
var gcd := 0.0
var cooldowns := {"strike": 0.0, "cleave": 0.0, "charge": 0.0, "mend":0.0,"lightning":0.0,"rend":0.0}
var enemies: Array = []
var auto_target := 0
var auto_timer := 0.0
var queued_ability := ""
var target := 0:
	set(value):
		if value != target: queued_ability = ""
		target = value
		auto_target = value if outcome == "" and value >= 0 and value < enemies.size() and enemies[value].hp > 0 else -1
var message := "Press 3 to charge the Ashguard, let automatic Strike build Momentum."
var elapsed := 0.0
var outcome := ""
var events: Array = []

func _init(): spawn_enemies()

func spawn_enemies():
	enemies.clear()
	for spec in [["Ashguard", "bruiser", Vector2(-3,-2), 300.0], ["Ember Seer", "caster", Vector2(3,-5), 200.0], ["Cinder Acolyte", "support", Vector2(0,-8), 180.0]]:
		enemies.append({"name":spec[0], "kind":spec[1], "pos":spec[2], "hp":spec[3]*(1.25 if encounter == 2 else 1.0), "max_hp":spec[3]*(1.25 if encounter == 2 else 1.0), "active_at": {"bruiser":0.0,"caster":10.0,"support":18.0}[spec[1]], "basic_timer":1.5, "timer":4.0, "cast":0.0, "aim":Vector2.ZERO, "interrupted":0.0,"vulnerable":0.0,"bleed":0.0,"bleed_tick":0.0,"shocked":0.0})

func choose_reward(id: String) -> bool:
	if outcome != "ENCOUNTER CLEARED" or encounter != 1 or not REWARDS.has(id): return false
	reward = id
	encounter = 2
	stop_auto_attack()
	spawn_enemies()
	target = 0
	player = Vector2(0,7)
	facing = Vector2(0,-1)
	health = minf(160,health+40)
	guard = 0
	guard_time = 0
	momentum = 30
	gcd = 0
	for ability in cooldowns: cooldowns[ability] = 0.0
	elapsed = 0
	outcome = ""
	auto_target = target
	events.clear()
	message = "Reward unlocked: %s. Press 4 to use it." % REWARDS[id].name
	return true

func alive() -> Array:
	return enemies.filter(func(e): return e.hp > 0)

func cycle_target():
	for i in range(1, enemies.size()+1):
		var candidate = (target+i)%enemies.size()
		if enemies[candidate].hp > 0:
			target = candidate
			return

func stop_auto_attack():
	auto_target = -1
	queued_ability = ""

func request_ability(id: String) -> bool:
	# Reserve the next shared cooldown for a manual command before auto Strike.
	if id in REWARDS and reward != id: return false
	if outcome != "": return false
	if auto_target != -1 and id not in ["strike","charge"] and ABILITIES.has(id) and gcd > 0 and cooldowns[id] <= 0:
		queued_ability = id
		message = "%s queued for the next global cooldown." % (REWARDS[id].name if id in REWARDS else id.capitalize())
		return true
	return use_ability(id)

func use_ability(id: String) -> bool:
	if outcome != "" or not ABILITIES.has(id): return false
	if id in REWARDS and reward != id: return false
	var a = ABILITIES[id]
	var e = enemies[target]
	if e.hp <= 0 and id != "mend":
		cycle_target()
		e = enemies[target]
	if (gcd > 0 and id not in ["strike","charge"]) or cooldowns[id] > 0 or (id == "strike" and auto_timer > 0):
		message = "Ability is recovering."
		return false
	if momentum < a.cost:
		message = "Need %d Momentum. Strike builds 15." % a.cost
		return false
	var offset: Vector2 = e.pos-player
	if id != "mend" and (offset.length() > a.range or e.hp <= 0):
		message = "Move closer to your target."
		return false
	if id == "mend" and health >= 160:
		message = "Already at full health."
		return false
	facing = offset.normalized()
	momentum -= a.cost
	if id not in ["strike","charge"]: gcd = 1.0
	cooldowns[id] = a.cooldown
	if id == "mend":
		var restored = minf(45,160-health)
		health += restored
		guard = 18
		guard_time = 6
		events.append({"kind":"recovery", "pos":player,"amount":restored})
		events.append({"kind":"mend", "pos":player})
		message = "Second Wind: +%d health and 18 Guard." % restored
		return true
	if id == "charge":
		var was_casting = e.cast > 0
		player = e.pos-facing*1.6
		e.cast = 0.0
		e.timer = 3.0
		e.interrupted = 1.5 if was_casting else 0.0
		if was_casting:
			e.vulnerable = 3.0
			stats.interrupts += 1
			events.append({"kind":"interrupt","pos":e.pos})
		message = "Charge! Target interrupted." if was_casting else "Charge! In melee range. Strike builds Momentum automatically."
	else:
		message = "Strike: +15 Momentum" if id == "strike" else "Cleave: frontal area damage"
	if id == "strike":
		momentum = minf(100, momentum+15)
		auto_timer = 1.0
	for victim in enemies:
		if victim.hp <= 0: continue
		var delta: Vector2 = victim.pos-player
		if victim == e or (id == "cleave" and delta.length() <= a.range and facing.dot(delta.normalized()) > 0.35):
			var primed: bool = victim.shocked > 0
			var bleeding: bool = victim.bleed > 0
			damage_enemy(victim,a.damage)
			if primed and id in ["cleave","charge"]:
				victim.shocked = 0
				stats.combos += 1
				for nearby in enemies:
					if nearby.pos.distance_to(victim.pos) <= 3.5: damage_enemy(nearby,24,"combo")
				events.append({"kind":"combo","pos":victim.pos,"label":"TECH BURST"})
			if bleeding and id == "cleave":
				victim.bleed = 0
				victim.bleed_tick = 0
				damage_enemy(victim,26,"combo")
				stats.combos += 1
				events.append({"kind":"combo","pos":victim.pos,"label":"RUPTURE"})
			if id == "lightning" and victim.hp > 0: victim.shocked = 5.0
			if id == "rend" and victim.hp > 0:
				victim.bleed = 5.0
				victim.bleed_tick = 0.0
	if id in REWARDS: message = "%s!" % REWARDS[id].name
	events.append({"kind":id,"pos":player,"direction":facing,"target_pos":e.pos})
	if auto_target != -1 and enemies[auto_target].hp <= 0: stop_auto_attack()
	if alive().is_empty(): outcome = "ENCOUNTER CLEARED" if encounter == 1 else "RUN COMPLETE"
	return true

func step(dt: float, movement: Vector2):
	if outcome != "": return
	elapsed += dt
	guard_time = maxf(0,guard_time-dt)
	if guard_time <= 0: guard = 0
	gcd = maxf(0, gcd-dt)
	for id in cooldowns: cooldowns[id] = maxf(0,cooldowns[id]-dt)
	if movement.length() > 0:
		facing = movement.normalized()
		player += facing*5.0*dt
		player = player.clamp(Vector2(-13,-13),Vector2(13,13))
	for e in enemies:
		if e.hp <= 0: continue
		e.interrupted = maxf(0,e.interrupted-dt)
		e.vulnerable = maxf(0,e.vulnerable-dt)
		e.shocked = maxf(0,e.shocked-dt)
		if e.bleed > 0:
			e.bleed_tick += minf(dt,e.bleed)
			e.bleed = maxf(0,e.bleed-dt)
			while e.bleed_tick >= 0.9999 and e.hp > 0:
				e.bleed_tick -= 1.0
				damage_enemy(e,6,"bleed")
		if e.hp <= 0: continue
		if elapsed < e.active_at and e.cast <= 0: continue
		if e.cast > 0:
			e.cast -= dt
			if e.cast <= 0:
				if e.kind == "bruiser":
					var delta: Vector2 = player-e.pos
					if delta.length() < 4.5 and delta.normalized().dot(e.aim) > 0.6: take_damage(30, "Ashguard heavy swing",true)
				elif e.kind == "caster":
					if player.distance_to(e.aim) < 2.6: take_damage(24, "Ember Seer ground blast",true)
				else:
					for ally in alive():
						var restored = minf(8,ally.max_hp-ally.hp)
						ally.hp += restored
						if restored > 0: events.append({"kind":"enemy_heal", "pos":ally.pos,"amount":restored})
				e.timer = {"bruiser":12.0,"caster":14.0,"support":10.0}[e.kind]
			events.append({"kind":"enemy_cast","pos":e.pos,"aim":e.aim,"enemy_kind":e.kind})
			continue
		var offset: Vector2 = player-e.pos
		e.basic_timer = maxf(0,e.basic_timer-dt)
		if e.interrupted <= 0 and e.basic_timer <= 0:
			if e.kind == "bruiser" and offset.length() <= 2.8:
				take_damage(6,"Ashguard basic hit")
				e.basic_timer = 2.2
				events.append({"kind":"enemy_basic","pos":e.pos,"enemy_kind":e.kind})
			elif e.kind == "caster" and offset.length() <= 16:
				take_damage(4,"Ember Seer basic bolt")
				e.basic_timer = 3.2
				events.append({"kind":"enemy_basic","pos":e.pos,"enemy_kind":e.kind})
		if e.kind == "bruiser" and offset.length() > 2.3:
			e.pos += offset.normalized()*2.1*dt
		e.timer -= dt
		if e.timer <= 0 and (e.kind != "bruiser" or offset.length() <= 4.5) and not enemies.any(func(other): return other.hp > 0 and other.cast > 0):
			e.cast = 2.4 if e.kind != "support" else 3.0
			e.aim = offset.normalized() if e.kind == "bruiser" else player
	if alive().is_empty(): outcome = "ENCOUNTER CLEARED" if encounter == 1 else "RUN COMPLETE"
	health = maxf(0,health)
	if health <= 0: outcome = "YOU HAVE FALLEN"
	if outcome != "":
		stop_auto_attack()
		return
	auto_timer = maxf(0,auto_timer-dt)
	if auto_target != -1 and (auto_target != target or enemies[auto_target].hp <= 0): stop_auto_attack()
	if queued_ability != "" and gcd <= 0:
		var command = queued_ability
		queued_ability = ""
		use_ability(command)
	elif auto_target != -1 and auto_timer <= 0 and player.distance_to(enemies[auto_target].pos) <= ABILITIES.strike.range:
		use_ability("strike")

func damage_enemy(e: Dictionary, base_damage: float, source: String = "hit"):
	if e.hp <= 0: return
	var damage = base_damage*(1.25 if e.vulnerable > 0 else 1.0)
	e.hp = maxf(0,e.hp-damage)
	events.append({"kind":"enemy_hit","pos":e.pos,"amount":damage,"source":source})
	if e.hp <= 0:
		var restored = minf(8,160-health)
		health += restored
		if restored > 0: events.append({"kind":"recovery","pos":player,"amount":restored})

func take_damage(amount: float, source: String, special: bool = false):
	var absorbed = minf(guard,amount)
	guard -= absorbed
	amount -= absorbed
	stats.absorbed += absorbed
	if absorbed > 0: events.append({"kind":"guard","pos":player,"amount":absorbed})
	if amount <= 0: return
	stats["special_damage" if special else "basic_damage"] += minf(health,amount)
	health -= amount
	message = "%s: -%d health. %s" % [source,amount,"Interrupt or reposition for heavy attacks." if special else "Basic hits are expected; keep fighting."]
	events.append({"kind":"player_hit", "pos":player,"amount":amount,"special":special})

func in_danger(e: Dictionary) -> bool:
	if e.hp <= 0 or e.cast <= 0: return false
	if e.kind == "caster": return player.distance_to(e.aim) < 2.6
	if e.kind == "bruiser":
		var offset: Vector2 = player-e.pos
		return offset.length() < 4.5 and offset.normalized().dot(e.aim) > 0.6
	return false
