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
var target := 0
var message := "Prioritize the support. Charge interrupts spellcasts."
var elapsed := 0.0
var outcome := ""
var events: Array = []

func _init():
	for spec in [["Ashguard", "bruiser", Vector2(-3,-2), 150.0], ["Ember Seer", "caster", Vector2(3,-5), 100.0], ["Cinder Acolyte", "support", Vector2(0,-8), 90.0]]:
		enemies.append({"name":spec[0], "kind":spec[1], "pos":spec[2], "hp":spec[3], "max_hp":spec[3], "timer":2.0, "cast":0.0, "aim":Vector2.ZERO, "interrupted":0.0})

func alive() -> Array:
	return enemies.filter(func(e): return e.hp > 0)

func cycle_target():
	for i in range(1, enemies.size()+1):
		var candidate = (target+i)%enemies.size()
		if enemies[candidate].hp > 0:
			target = candidate
			return

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
		player = e.pos-facing*1.6
		e.cast = 0.0
		e.timer = 3.0
		e.interrupted = 1.0
		message = "Charge! Target interrupted."
	else:
		message = "Strike: +15 Momentum" if id == "strike" else "Cleave: frontal area damage"
	if id == "strike": momentum = minf(100, momentum+15)
	for victim in enemies:
		if victim.hp <= 0: continue
		var delta: Vector2 = victim.pos-player
		if victim == e or (id == "cleave" and delta.length() <= a.range and facing.dot(delta.normalized()) > 0.35):
			victim.hp = maxf(0, victim.hp-a.damage)
	events.append({"kind":id,"pos":player,"direction":facing})
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
		if e.cast > 0:
			e.cast -= dt
			if e.cast <= 0:
				if e.kind == "bruiser":
					var delta: Vector2 = player-e.pos
					if delta.length() < 4.5 and delta.normalized().dot(e.aim) > 0.6: health -= 26
				elif e.kind == "caster":
					if player.distance_to(e.aim) < 2.6: health -= 24
				else:
					for ally in alive(): ally.hp = minf(ally.max_hp,ally.hp+12)
				e.timer = 3.5 if e.kind != "support" else 6.0
			continue
		var offset: Vector2 = player-e.pos
		if e.kind == "bruiser" and offset.length() > 2.3:
			e.pos += offset.normalized()*2.1*dt
		e.timer -= dt
		if e.timer <= 0:
			e.cast = 1.6 if e.kind != "support" else 2.2
			e.aim = offset.normalized() if e.kind == "bruiser" else player
	health = maxf(0,health)
	if health <= 0: outcome = "YOU HAVE FALLEN"
