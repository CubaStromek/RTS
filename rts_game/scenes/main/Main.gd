extends Node2D
## Root scene — entry point. Sets up all game systems, entities, and UI.

const UnitScene := preload("res://scenes/units/Unit.tscn")
const WorkerScene := preload("res://scenes/units/Worker.tscn")
const ArcherScene := preload("res://scenes/units/Archer.tscn")
const KnightScene := preload("res://scenes/units/Knight.tscn")
const BarracksScene := preload("res://scenes/buildings/Barracks.tscn")
const TownHallScene := preload("res://scenes/buildings/TownHall.tscn")
const ResourceNodeScene := preload("res://scenes/map/ResourceNode.tscn")
const HUDScene := preload("res://scenes/ui/HUD.tscn")
const MinimapScene := preload("res://scenes/ui/Minimap.tscn")
const FogOfWarScript := preload("res://scripts/systems/FogOfWarSystem.gd")
const AIScript := preload("res://scripts/systems/AISystem.gd")

var hud: CanvasLayer = null

func _ready() -> void:
	print("Medieval RTS started!")
	GameManager.reset_state()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_setup_selection_box_style()
	_setup_hud()
	_setup_fog_of_war()
	if GameManager.game_mode == GameManager.GameMode.WAVES:
		_setup_ai()
	_spawn_player_base()
	_spawn_resources()
	if GameManager.game_mode == GameManager.GameMode.WAVES:
		_spawn_enemies()
	if GameManager.game_mode == GameManager.GameMode.SANDBOX:
		ResourceSystem.resources["gold"] = 1000
		ResourceSystem.resources["wood"] = 1000
	_connect_signals()

func _setup_selection_box_style() -> void:
	var box: Panel = $UI/SelectionBox
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.8, 0.0, 0.15)
	style.border_color = Color(0.0, 1.0, 0.0, 0.8)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	box.add_theme_stylebox_override("panel", style)

func _setup_hud() -> void:
	hud = HUDScene.instantiate()
	add_child(hud)
	# Add minimap to HUD layer
	var minimap := MinimapScene.instantiate()
	hud.add_child(minimap)

func _setup_fog_of_war() -> void:
	var fog := Node2D.new()
	fog.name = "FogOfWar"
	fog.set_script(FogOfWarScript)
	add_child(fog)

func _setup_ai() -> void:
	var ai := Node.new()
	ai.name = "AISystem"
	ai.set_script(AIScript)
	add_child(ai)

func _spawn_player_base() -> void:
	# Town Hall
	var town_hall := TownHallScene.instantiate()
	town_hall.global_position = Vector2(500, 500)
	town_hall.team = 0
	town_hall.add_to_group("buildings")
	town_hall.add_to_group("townhalls")
	town_hall.unit_trained.connect(_on_unit_trained)
	$Entities.add_child(town_hall)

	# Barracks
	var barracks := BarracksScene.instantiate()
	barracks.global_position = Vector2(650, 500)
	barracks.team = 0
	barracks.add_to_group("buildings")
	barracks.unit_trained.connect(_on_unit_trained)
	$Entities.add_child(barracks)

	# Starting soldiers
	for i in range(3):
		_spawn_unit(UnitScene, Vector2(400 + i * 50, 400), 0)

	# Starting archer
	_spawn_unit(ArcherScene, Vector2(550, 400), 0)

	# Starting workers
	for i in range(2):
		_spawn_unit(WorkerScene, Vector2(400 + i * 50, 600), 0)

func _spawn_resources() -> void:
	# Gold mines — multiple clusters
	var gold_positions := [
		Vector2(800, 300), Vector2(850, 350), Vector2(750, 350),
		Vector2(1200, 600), Vector2(1250, 650),
		Vector2(2000, 1000), Vector2(2050, 1050),
		Vector2(1500, 2000), Vector2(1550, 2050),
	]
	for pos in gold_positions:
		_spawn_resource_node(pos, "gold", 500)

	# Trees — larger forest areas
	var tree_positions := [
		Vector2(300, 200), Vector2(340, 230), Vector2(280, 260),
		Vector2(320, 190), Vector2(360, 250),
		Vector2(200, 350), Vector2(240, 380), Vector2(180, 400),
		Vector2(1000, 400), Vector2(1040, 430), Vector2(1080, 400),
		Vector2(1020, 460), Vector2(1060, 440),
		Vector2(800, 1200), Vector2(840, 1230), Vector2(860, 1200),
	]
	for pos in tree_positions:
		_spawn_resource_node(pos, "wood", 300)

func _spawn_enemies() -> void:
	# Initial enemy patrol near center
	for i in range(3):
		var unit := UnitScene.instantiate()
		unit.global_position = Vector2(2000 + i * 50, 2000)
		unit.team = 1
		$Entities.add_child(unit)

	# Enemy archers
	for i in range(2):
		var archer := ArcherScene.instantiate()
		archer.global_position = Vector2(2100 + i * 50, 2050)
		archer.team = 1
		$Entities.add_child(archer)

func _connect_signals() -> void:
	SelectionSystem.building_selected.connect(_on_building_selected)
	SelectionSystem.building_deselected.connect(_on_building_deselected)

func _on_building_selected(building: StaticBody2D) -> void:
	if hud:
		hud.show_building_info(building)

func _on_building_deselected() -> void:
	pass

func _on_unit_trained(building: StaticBody2D, unit_type: String) -> void:
	var scene: PackedScene
	match unit_type:
		"soldier":
			scene = UnitScene
		"worker":
			scene = WorkerScene
		"archer":
			scene = ArcherScene
		"knight":
			scene = KnightScene
		_:
			scene = UnitScene
	var unit := _spawn_unit(scene, building.rally_point, building.team)
	# Apply existing tech upgrades to new friendly units
	if building.team == 0:
		var tech := get_node_or_null("/root/TechSystem")
		if tech:
			tech.apply_all_to_new_unit(unit)
	var snd := get_node_or_null("/root/SoundSystem")
	if snd:
		snd.play("build_complete")
	var notify := get_node_or_null("/root/NotificationSystem")
	if notify and building.team == 0:
		notify.notify("%s trained!" % unit_type.capitalize())

func _spawn_unit(scene: PackedScene, pos: Vector2, team: int) -> CharacterBody2D:
	var unit: CharacterBody2D = scene.instantiate()
	unit.global_position = pos
	unit.team = team
	$Entities.add_child(unit)
	return unit

func _spawn_resource_node(pos: Vector2, type: String, amount: int) -> void:
	var node: StaticBody2D = ResourceNodeScene.instantiate()
	node.global_position = pos
	node.resource_type = type
	node.amount = amount
	node.add_to_group("resources")
	$Entities.add_child(node)
