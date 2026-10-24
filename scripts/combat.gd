extends RefCounted
## Rendering-independent simulation. Inputs are commands; presentation reads state.
const ABILITIES = {
	"strike": {"range": 2.8, "cost": 0, "cooldown": 0.0, "damage": 18.0},
	"cleave": {"range": 3.8, "cost": 30, "cooldown": 4.0, "damage": 38.0},
	"charge": {"range": 13.0, "cost": 0, "cooldown": 8.0, "damage": 12.0}
}
var player := Vector2(0, 7)
var facing := Vector2(0, -1)
var health := 160.0
var momentum := 0.0
var gcd := 0.0
var cooldowns := {"strike": 0.0, "cleave": 0.0, "charge": 0.0}
var enemies: Array = []
var auto_target := -1
var auto_timer := 0.0
var queued_ability := ""
var target := 0:
	set(value):
		if value != target: stop_auto_attack()
		target = value
var message := "Press 3 to charge the Ashguard, then 1 to build Momentum."
var elapsed := 0.0
var outcome := ""
var events: Array = []

func _init():
	for spec in [["Ashguard", "bruiser", Vector2(-3,-2), 150.0], ["Ember Seer", "caster", Vector2(3,-5), 100.0], ["Cinder Acolyte", "support", Vector2(0,-8), 90.0]]:
		enemies.append({"name":spec[0], "kind":spec[1], "pos":spec[2], "hp":spec[3], "max_hp":spec[3], "active_at": {"bruiser":0.0,"caster":10.0,"support":18.0}[spec[1]], "timer":3.0, "cast":0.0, "aim":Vector2.ZERO, "interrupted":0.0})

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

func toggle_auto_attack():
	if auto_target != -1:
		stop_auto_attack()
		message = "Auto-attack off."
	elif outcome == "" and enemies[target].hp > 0:
		auto_target = target
		auto_timer = 0.0
		message = "Auto-attack on: %s. Shift+1 turns it off." % enemies[target].name

func request_ability(id: String) -> bool:
	# Reserve the next shared cooldown for a manual command before auto Strike.
	if auto_target != -1 and id != "strike" and ABILITIES.has(id) and gcd > 0 and cooldowns[id] <= 0:
		queued_ability = id
		message = "%s queued for the next global cooldown." % id.capitalize()
		return true
	return use_ability(id)

func use_ability(id: String) -> bool:
	if outcome != "" or not ABILITIES.has(id): return false
	var a = ABILITIES[id]
	var e = enemies[target]
	if e.hp <= 0:
		cycle_target()
		e = enemies[target]
	if gcd > 0 or cooldowns[id] > 0:
		message = "Ability is recovering."
		return false
	if momentum < a.cost:
		message = "Need 30 Momentum. Strike builds 15."
		return false
	var offset: Vector2 = e.pos-player
	if offset.length() > a.range or e.hp <= 0:
		message = "Move closer to your target."
		return false
	facing = offset.normalized()
	momentum -= a.cost
	gcd = 1.0
	cooldowns[id] = a.cooldown
	if id == "charge":
		var was_casting = e.cast > 0
		player = e.pos-facing*1.6
		e.cast = 0.0
		e.timer = 3.0
		e.interrupted = 1.0 if was_casting else 0.0
		message = "Charge! Target interrupted." if was_casting else "Charge! In melee range. Use 1 to build Momentum."
	else:
		message = "Strike: +15 Momentum" if id == "strike" else "Cleave: frontal area damage"
	if id == "strike":
		momentum = minf(100, momentum+15)
		auto_timer = 1.0
	for victim in enemies:
		if victim.hp <= 0: continue
		var delta: Vector2 = victim.pos-player
		if victim == e or (id == "cleave" and delta.length() <= a.range and facing.dot(delta.normalized()) > 0.35):
			victim.hp = maxf(0, victim.hp-a.damage)
			events.append({"kind":"enemy_hit", "pos":victim.pos, "amount":a.damage})
			if victim.hp <= 0:
				var restored = minf(20,160-health)
				health += restored
				if restored > 0: events.append({"kind":"recovery", "pos":player, "amount":restored})
	events.append({"kind":id,"pos":player,"direction":facing})
	if auto_target != -1 and enemies[auto_target].hp <= 0: stop_auto_attack()
	if alive().is_empty(): outcome = "ENCOUNTER CLEARED"
	return true

func step(dt: float, movement: Vector2):
	if outcome != "": return
	elapsed += dt
	gcd = maxf(0, gcd-dt)
	for id in cooldowns: cooldowns[id] = maxf(0,cooldowns[id]-dt)
	if movement.length() > 0:
		facing = movement.normalized()
		player += facing*5.0*dt
		player = player.clamp(Vector2(-13,-13),Vector2(13,13))
	for e in enemies:
		if e.hp <= 0: continue
		e.interrupted = maxf(0,e.interrupted-dt)
		if elapsed < e.active_at and e.cast <= 0: continue
		if e.cast > 0:
			e.cast -= dt
			if e.cast <= 0:
				if e.kind == "bruiser":
					var delta: Vector2 = player-e.pos
					if delta.length() < 4.5 and delta.normalized().dot(e.aim) > 0.6: take_damage(16, "Ashguard frontal swing")
				elif e.kind == "caster":
					if player.distance_to(e.aim) < 2.6: take_damage(14, "Ember Seer ground blast")
				else:
					for ally in alive():
						var restored = minf(8,ally.max_hp-ally.hp)
						ally.hp += restored
						if restored > 0: events.append({"kind":"enemy_heal", "pos":ally.pos,"amount":restored})
				e.timer = 4.5 if e.kind != "support" else 7.0
			continue
		var offset: Vector2 = player-e.pos
		if e.kind == "bruiser" and offset.length() > 2.3:
			e.pos += offset.normalized()*2.1*dt
		e.timer -= dt
		if e.timer <= 0:
			e.cast = 2.4 if e.kind != "support" else 3.0
			e.aim = offset.normalized() if e.kind == "bruiser" else player
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
	elif auto_target != -1 and auto_timer <= 0 and gcd <= 0 and player.distance_to(enemies[auto_target].pos) <= ABILITIES.strike.range:
		use_ability("strike")

func take_damage(amount: float, source: String):
	health -= amount
	message = "%s hit you for %d. Move out of the marked area." % [source,amount]
	events.append({"kind":"player_hit", "pos":player,"amount":amount})

func in_danger(e: Dictionary) -> bool:
	if e.hp <= 0 or e.cast <= 0: return false
	if e.kind == "caster": return player.distance_to(e.aim) < 2.6
	if e.kind == "bruiser":
		var offset: Vector2 = player-e.pos
		return offset.length() < 4.5 and offset.normalized().dot(e.aim) > 0.6
	return false
