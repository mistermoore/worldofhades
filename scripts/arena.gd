extends Node3D
const Combat = preload("res://scripts/combat.gd")
var sim = Combat.new()
var hero: Node3D
var foes: Array = []
var camera: Camera3D
var yaw := 0.0
var pitch := 0.62
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
		label.font_size = 40
		label.pixel_size = 0.008
		label.position.y = 2.5
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		foe.add_child(label)
		markers.append(circle(2.6,Color("ed735e")))
	ring = circle(0.85,Color("e5c477"))
	camera = Camera3D.new()
	camera.fov = 65
	add_child(camera)
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var panel = ColorRect.new()
	panel.color = Color(0.035,0.055,0.075,0.92)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 100
	canvas.add_child(panel)
	hud = Label.new()
	hud.position = Vector2(28,15)
	hud.add_theme_font_size_override("font_size",22)
	canvas.add_child(hud)
	status = Label.new()
	status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	status.offset_top = -165
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
		b.pressed.connect(func(): sim.use_ability(id))
		bar.add_child(b)
		buttons.append(b)
	var restart = Button.new()
	restart.focus_mode = Control.FOCUS_NONE
	restart.text = "R  ·  Restart encounter"
	restart.position = Vector2(1000,27)
	restart.pressed.connect(reset)
	canvas.add_child(restart)

func reset():
	sim = Combat.new()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x*0.005
		pitch = clampf(pitch+event.relative.y*0.003,0.2,1.1)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_TAB:
				sim.cycle_target()
				get_viewport().set_input_as_handled()
			KEY_1: sim.use_ability("strike")
			KEY_2: sim.use_ability("cleave")
			KEY_3: sim.use_ability("charge")
			KEY_R: reset()

func _process(dt):
	clock += dt
	var input = Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	sim.step(minf(dt,0.05),input.rotated(-yaw))
	hero.position = Vector3(sim.player.x,0,sim.player.y)
	hero.rotation.y = atan2(-sim.facing.x,-sim.facing.y)
	for event in sim.events:
		flash = 0.2
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
		label.text = "%s  %d/%d\n%s" % [e.name,e.hp,e.max_hp,("CASTING  %.1fs"%e.cast) if e.cast>0 else ("INTERRUPTED" if e.interrupted>0 else e.kind.to_upper())]
		markers[i].visible = e.hp > 0 and e.cast > 0
		var pos: Vector2 = e.aim if e.kind == "caster" else e.pos
		markers[i].position = Vector3(pos.x,0.12,pos.y)
		if e.kind == "bruiser":
			markers[i].position += Vector3(e.aim.x,0,e.aim.y)*2
			markers[i].scale = Vector3(0.65,0.3,0.65)
		else: markers[i].scale = Vector3.ONE
	var target = sim.enemies[sim.target]
	ring.visible = target.hp > 0
	ring.position = Vector3(target.pos.x,0.15,target.pos.y)
	camera.position = hero.position+Vector3(sin(yaw)*9*cos(pitch),9*sin(pitch)+2,cos(yaw)*9*cos(pitch))
	camera.look_at(hero.position+Vector3(0,1,0))
	hud.text = "WORLD OF HADES   /   THE ASHEN PROVING GROUNDS\nHealth %d / 160     •     Momentum %d / 100     •     Enemies %d / 3" % [sim.health,sim.momentum,sim.alive().size()]
	status.text = (sim.outcome+"  ·  Press R to try again" if sim.outcome != "" else sim.message)+"\nWASD move   ·   Hold right mouse to orbit   ·   Tab target   ·   1–3 abilities"
	var ids = ["strike","cleave","charge"]
	var descriptions = ["+15 Momentum · 2.8m","30 Momentum · frontal cone","13m · interrupt · 8s cooldown"]
	for i in range(3):
		var cd: float = maxf(sim.gcd,sim.cooldowns[ids[i]])
		buttons[i].text = "%d  %s%s\n%s" % [i+1,ids[i].capitalize(),("  %.1fs"%cd) if cd>0 else "",descriptions[i]]
		buttons[i].disabled = cd>0 or sim.outcome != "" or (i==1 and sim.momentum<30)
