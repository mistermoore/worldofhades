extends Node3D
const Combat = preload("res://scripts/combat.gd")
var sim = Combat.new()
var hero: Node3D
var foes: Array = []
var camera: Camera3D
var yaw := 0.0
var pitch := 0.35
var distance := 7.5
var paused := true
var started := false
var intro: PanelContainer
var intro_text: Label
var start_button: Button
var warning: Label
var target_info: Label
var hp_bar: ProgressBar
var resource_bar: ProgressBar
var damage_overlay: ColorRect
var damage_flash := 0.0
var transient: Array = []
var hud: Label
var status: Label
var buttons: Array = []
var markers: Array = []
var ring: MeshInstance3D
var flash := 0.0
var clock := 0.0

func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	if glow:
		m.emission_enabled = true
		m.emission = color
	return m

func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var shape = BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = material(color)
	parent.add_child(mesh)
	mesh.position = pos
	return mesh

func circle(radius: float, color: Color) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = TorusMesh.new()
	mesh.inner_radius = radius-0.06
	mesh.outer_radius = radius+0.06
	n.mesh = mesh
	n.material_override = material(color,true)
	add_child(n)
	return n

func character(color: Color) -> Node3D:
	var root = Node3D.new()
	add_child(root)
	var body = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.7
	body.mesh = capsule
	body.material_override = material(color)
	root.add_child(body)
	body.position.y = 0.95
	box(root,Vector3(0,1.7,-0.25),Vector3(0.5,0.16,0.25),Color("e8d5a2"))
	box(root,Vector3(0.65,0.9,-0.3),Vector3(0.12,1.1,0.18),Color("b9c9cf"))
	return root

func _ready():
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("101820")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("92a8c5")
	env.environment.ambient_light_energy = 0.65
	add_child(env)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50,-30,0)
	sun.light_color = Color("ffd8ac")
	sun.light_energy = 1.4
	add_child(sun)
	box(self,Vector3(0,-0.3,0),Vector3(29,0.5,29),Color("26323a"))
	for x in range(-7,8):
		for z in range(-7,8):
			box(self,Vector3(x*2,0,z*2),Vector3(1.94,0.07,1.94),Color("303c44") if (x+z)%2==0 else Color("34414a"))
	for i in range(-3,4):
		for side in [-1,1]:
			box(self,Vector3(i*4,1.2,side*14.5),Vector3(1.1,2.5,1.1),Color("202a35"))
			box(self,Vector3(side*14.5,1.2,i*4),Vector3(1.1,2.5,1.1),Color("202a35"))
	for p in [Vector3(-11,0,-11),Vector3(11,0,-11),Vector3(-11,0,11),Vector3(11,0,11)]:
		box(self,p+Vector3(0,0.7,0),Vector3(0.8,1.4,0.8),Color("564536"))
		box(self,p+Vector3(0,1.5,0),Vector3(0.5,0.25,0.5),Color("ff9a45"))
		var light = OmniLight3D.new()
		add_child(light)
		light.position = p+Vector3(0,2,0)
		light.light_color = Color("ff943d")
		light.omni_range = 7
	hero = character(Color("62b9b0"))
	for e in sim.enemies:
		var color = {"bruiser":Color("c76651"),"caster":Color("a77dda"),"support":Color("d3b466")}[e.kind]
		var foe = character(color)
		foes.append(foe)
		var label = Label3D.new()
		label.font_size = 44
		label.pixel_size = 0.008
		label.position.y = 2.7
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		foe.add_child(label)
		markers.append(telegraph(e.kind))
	ring = circle(0.85,Color("e5c477"))
	camera = Camera3D.new()
	camera.fov = 70
	add_child(camera)
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var panel = ColorRect.new()
	panel.color = Color(0.035,0.055,0.075,0.92)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 115
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(panel)
	hud = Label.new()
	hud.position = Vector2(28,15)
	hud.add_theme_font_size_override("font_size",20)
	canvas.add_child(hud)
	status = Label.new()
	status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	status.offset_top = -205
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size",18)
	canvas.add_child(status)
	var bar = HBoxContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	bar.position = Vector2(-310, -115)
	bar.add_theme_constant_override("separation",12)
	canvas.add_child(bar)
	for id in ["strike","cleave","charge"]:
		var b = Button.new()
		b.custom_minimum_size = Vector2(195,75)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func():
			if not paused: sim.request_ability(id))
		bar.add_child(b)
		buttons.append(b)
	var restart = Button.new()
	restart.focus_mode = Control.FOCUS_NONE
	restart.text = "R  ·  Restart encounter"
	restart.position = Vector2(1060,20)
	restart.pressed.connect(reset)
	canvas.add_child(restart)
	hp_bar = meter(canvas,Vector2(28,83),Color("65c19a"),160)
	resource_bar = meter(canvas,Vector2(360,83),Color("e4b75f"),100)
	target_info = Label.new()
	target_info.position = Vector2(700,45)
	target_info.add_theme_font_size_override("font_size",18)
	canvas.add_child(target_info)
	warning = Label.new()
	warning.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	warning.offset_top = 125
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_font_size_override("font_size",24)
	warning.add_theme_color_override("font_color",Color("ffe6a0"))
	warning.add_theme_color_override("font_shadow_color",Color.BLACK)
	warning.add_theme_constant_override("shadow_offset_x",2)
	warning.add_theme_constant_override("shadow_offset_y",2)
	canvas.add_child(warning)
	damage_overlay = ColorRect.new()
	damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(damage_overlay)
	intro = PanelContainer.new()
	var intro_style = StyleBoxFlat.new()
	intro_style.bg_color = Color(0.035,0.055,0.075,1.0)
	intro_style.border_color = Color("526d74")
	intro_style.set_border_width_all(2)
	intro.add_theme_stylebox_override("panel",intro_style)
	intro.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	intro.position = Vector2(-300,-150)
	intro.custom_minimum_size = Vector2(600,300)
	var margin = MarginContainer.new()
	for edge in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+edge,24)
	intro.add_child(margin)
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation",16)
	margin.add_child(content)
	intro_text = Label.new()
	intro_text.add_theme_font_size_override("font_size",20)
	intro_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(intro_text)
	start_button = Button.new()
	start_button.custom_minimum_size.y = 48
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.pressed.connect(toggle_pause)
	content.add_child(start_button)
	canvas.add_child(intro)
	var you = Label3D.new()
	you.text = "YOU"
	you.position.y = 2.3
	you.font_size = 32
	you.pixel_size = 0.008
	you.modulate = Color("89edda")
	you.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hero.add_child(you)
	circle(0.55,Color("62b9b0")).reparent(hero,false)


func reset():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	sim = Combat.new()
	paused = true
	started = false
	yaw = 0
	pitch = 0.35
	distance = 7.5
	damage_flash = 0
	for item in transient: item.node.queue_free()
	transient.clear()

func toggle_pause():
	if sim.outcome != "": return
	paused = not paused
	if paused: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	started = true

func meter(canvas: CanvasLayer, pos: Vector2, color: Color, maximum: float) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = pos
	bar.size = Vector2(300,12)
	bar.max_value = maximum
	bar.show_percentage = false
	var style = StyleBoxFlat.new()
	style.bg_color = color
	bar.add_theme_stylebox_override("fill",style)
	canvas.add_child(bar)
	return bar

func telegraph(kind: String) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var vertices = PackedVector3Array()
	var angle = acos(0.6) if kind == "bruiser" else PI
	var radius = 4.5 if kind == "bruiser" else 2.6
	for i in range(48):
		var a = -angle+2*angle*i/48
		var b = -angle+2*angle*(i+1)/48
		vertices.append(Vector3.ZERO)
		vertices.append(Vector3(sin(a)*radius,0,-cos(a)*radius))
		vertices.append(Vector3(sin(b)*radius,0,-cos(b)*radius))
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var shape = ArrayMesh.new()
	shape.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	mesh.mesh = shape
	var m = material(Color(0.95,0.25,0.13,0.5) if kind != "support" else Color(0.3,0.85,0.55,0.35),true)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = m
	add_child(mesh)
	return mesh

func floating_text(pos: Vector2, text: String, color: Color):
	var label = Label3D.new()
	label.text = text
	label.font_size = 52
	label.pixel_size = 0.009
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = color
	add_child(label)
	label.position = Vector3(pos.x,2.4,pos.y)
	transient.append({"node":label,"remaining":1.2})


func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.shift_pressed and event.physical_keycode == KEY_1:
		if not paused: sim.toggle_auto_attack()
		get_viewport().set_input_as_handled()
	# Pause must work even while a mouse press has a HUD control focused.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE,KEY_P,KEY_ESCAPE]:
		toggle_pause()
		get_viewport().set_input_as_handled()
	# Releases must reach us even when the pointer is over a HUD control.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT and not paused and sim.outcome == "":
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: distance = maxf(4,distance-0.75)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: distance = minf(18,distance+0.75)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x*0.005
		pitch = clampf(pitch+event.relative.y*0.003,-0.05,0.95)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_TAB:
				sim.cycle_target()
				get_viewport().set_input_as_handled()
			KEY_1:
				if not paused:
					if event.shift_pressed: sim.toggle_auto_attack()
					else: sim.use_ability("strike")
			KEY_2: if not paused: sim.request_ability("cleave")
			KEY_3: if not paused: sim.request_ability("charge")
			KEY_R: reset()
			KEY_C: yaw = 0; pitch = 0.35; distance = 7.5

func _process(dt):
	clock += dt
	var input = Vector2(float(Input.is_physical_key_pressed(KEY_E))-float(Input.is_physical_key_pressed(KEY_Q)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	if not paused and sim.outcome == "":
		var turn = float(Input.is_physical_key_pressed(KEY_A))-float(Input.is_physical_key_pressed(KEY_D))
		yaw += turn*1.8*minf(dt,0.05)
	# WoW-style mouse steering: both buttons act as forward, in camera space.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		input.y = -1
	if not paused: sim.step(minf(dt,0.05),input.rotated(-yaw))
	if sim.outcome != "": Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hero.position = Vector3(sim.player.x,0,sim.player.y)
	hero.rotation.y = yaw
	sim.facing = Vector2(0,-1).rotated(-yaw)
	for event in sim.events:
		match event.kind:
			"enemy_hit": floating_text(event.pos,"-%d"%event.amount,Color("ffe0a4"))
			"player_hit":
				damage_flash = 0.5
				floating_text(event.pos,"-%d HP"%event.amount,Color("ff8276"))
			"recovery": floating_text(event.pos,"+%d HP"%event.amount,Color("7aefb6"))
			"enemy_heal": floating_text(event.pos,"+%d"%event.amount,Color("7aefb6"))
			_: flash = 0.2
	for item in transient:
		item.remaining -= dt
		item.node.position.y += dt*0.8
		item.node.modulate.a = clampf(item.remaining,0,1)
	for i in range(transient.size()-1,-1,-1):
		if transient[i].remaining <= 0:
			transient[i].node.queue_free()
			transient.remove_at(i)
	damage_flash = maxf(0,damage_flash-dt)
	damage_overlay.color = Color(0.8,0.05,0.02,damage_flash*0.35)
	sim.events.clear()
	flash = maxf(0,flash-dt)
	hero.scale = Vector3.ONE*(1.1 if flash > 0 else 1.0)
	for i in range(foes.size()):
		var e = sim.enemies[i]
		var foe = foes[i]
		foe.visible = e.hp > 0
		foe.position = Vector3(e.pos.x,0,e.pos.y)
		var direction: Vector2 = sim.player-e.pos
		if e.cast > 0 and e.kind == "bruiser": direction = e.aim
		foe.rotation.y = atan2(-direction.x,-direction.y)
		var label: Label3D = foe.get_child(3)
		var cast_name = {"bruiser":"FRONTAL SWING - move behind", "caster":"GROUND BLAST - leave the circle", "support":"HEALING ALLIES - interrupt with 3"}[e.kind]
		var state = ("%s  %.1fs"%[cast_name,e.cast]) if e.cast>0 else ("INTERRUPTED" if e.interrupted>0 else ("WATCHING" if sim.elapsed<e.active_at else e.kind.to_upper()))
		label.text = "%s  %d/%d\n%s" % [e.name,e.hp,e.max_hp,state]
		markers[i].visible = e.hp > 0 and e.cast > 0
		var pos: Vector2 = e.aim if e.kind == "caster" else e.pos
		markers[i].position = Vector3(pos.x,0.12,pos.y)
		markers[i].rotation.y = atan2(-e.aim.x,-e.aim.y) if e.kind == "bruiser" else 0.0
		markers[i].material_override.albedo_color.a = 0.35+0.18*(0.5+0.5*sin(clock*8))
	var target = sim.enemies[sim.target]
	ring.visible = target.hp > 0
	ring.position = Vector3(target.pos.x,0.15,target.pos.y)
	var shoulder = Vector3(cos(yaw),0,-sin(yaw))
	var forward = Vector3(-sin(yaw),0,-cos(yaw))
	var pivot = hero.position+Vector3(0,1.6,0)
	camera.position = pivot+shoulder*1.1+Vector3(sin(yaw)*distance*cos(pitch),distance*sin(pitch),cos(yaw)*distance*cos(pitch))
	camera.look_at(pivot+forward*3.0+shoulder*0.6)
	hp_bar.value = sim.health
	resource_bar.value = sim.momentum
	target_info.text = "TARGET: %s  %d / %d\nDistance %.1fm" % [target.name,target.hp,target.max_hp,sim.player.distance_to(target.pos)]
	warning.text = "Defeat all three enemies. Each defeat restores 20 health."
	for e in sim.enemies:
		if e.hp <= 0 or e.cast <= 0: continue
		if sim.in_danger(e):
			warning.text = ("MOVE OUT OF THE CONE" if e.kind == "bruiser" else "MOVE OUT OF THE CIRCLE")+"  -  %.1fs"%e.cast
			break
		if e.kind == "support": warning.text = "Acolyte is healing - Tab to target, then 3 to interrupt"
	intro.visible = paused and sim.outcome == ""
	status.visible = not paused
	warning.visible = not paused
	intro_text.text = "THE ASHEN PROVING GROUNDS\n\nW/S: forward/back. Q/E: strafe. A/D: turn.\nHold both mouse buttons to run and steer.\nRight-drag looks. Scroll zooms. C resets view.\n\nTab selects a target. 3 charges into melee range.\n1: Strike. Shift+1: toggle auto-Strike on this target.\nUse 2 to spend Momentum on Cleave.\nLeave red danger zones before the countdown ends.\n\nEnemies join gradually. P pauses whenever you need."
	if started: intro_text.text = "PAUSED\n\nTake a breath. Nothing moves while paused.\n\n1: Strike builds Momentum   /   2: Cleave spends it\n3: Charge closes distance and interrupts\n\nW/S move   /   Q/E strafe   /   A/D turn\nScroll zoom   /   C resets view"
	start_button.text = "Space  -  Resume" if started else "Space  -  Begin encounter"
	hud.text = "WORLD OF HADES   /   THE ASHEN PROVING GROUNDS\nHealth %d / 160     •     Momentum %d / 100     •     Enemies %d / 3" % [sim.health,sim.momentum,sim.alive().size()]
	var auto_status = "Auto-attack OFF  |  Shift+1: enable on selected target"
	if sim.auto_target != -1:
		auto_status = "Auto-attack ON: %s%s" % [target.name," - move into melee range" if sim.player.distance_to(target.pos)>2.8 else ""]
	status.text = auto_status+"\n"+(sim.outcome+"  ·  Press R to try again" if sim.outcome != "" else sim.message)+"\nW/S move   ·   Q/E strafe   ·   A/D turn   ·   Both mouse: run + steer   ·   Scroll: zoom   ·   P: pause   ·   1–3: abilities"
	var ids = ["strike","cleave","charge"]
	var descriptions = ["Shift+1: auto on/off","30 Momentum · frontal cone","13m · interrupt · 8s cooldown"]
	for i in range(3):
		var cd: float = maxf(sim.gcd,sim.cooldowns[ids[i]])
		buttons[i].text = "%d  %s%s\n%s" % [i+1,ids[i].capitalize(),("  %.1fs"%cd) if cd>0 else "",descriptions[i]]
		buttons[i].disabled = paused or (cd>0 and not (sim.auto_target != -1 and i>0 and sim.cooldowns[ids[i]]<=0)) or sim.outcome != "" or (i==1 and sim.momentum<30)
