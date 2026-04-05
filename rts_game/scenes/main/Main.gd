extends Node2D
## Root scene — entry point. Sets up buildings, units, resources, enemies, and HUD.

const UnitScene := preload("res://scenes/units/Unit.tscn")
const WorkerScene := preload("res://scenes/units/Worker.tscn")
const BarracksScene := preload("res://scenes/buildings/Barracks.tscn")
const TownHallScene := preload("res://scenes/buildings/TownHall.tscn")
const ResourceNodeScene := preload("res://scenes/map/ResourceNode.tscn")
const HUDScene := preload("res://scenes/ui/HUD.tscn")

var hud: CanvasLayer = null

func _ready() -> void:
	print("Medieval RTS started!")
	_setup_selection_box_style()
	_setup_hud()
	_spawn_player_base()
	_spawn_resources()
	_spawn_enemies()
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

	# Starting workers
	for i in range(2):
		_spawn_unit(WorkerScene, Vector2(400 + i * 50, 600), 0)

func _spawn_resources() -> void:
	# Gold mines
	var gold_positions := [
		Vector2(800, 300), Vector2(850, 350), Vector2(750, 350),
		Vector2(1200, 600), Vector2(1250, 650),
	]
	for pos in gold_positions:
		_spawn_resource_node(pos, "gold", 500)

	# Trees
	var tree_positions := [
		Vector2(300, 200), Vector2(340, 230), Vector2(280, 260),
		Vector2(320, 190), Vector2(360, 250),
		Vector2(200, 350), Vector2(240, 380), Vector2(180, 400),
	]
	for pos in tree_positions:
		_spawn_resource_node(pos, "wood", 300)

func _spawn_enemies() -> void:
	# Enemy group at far side of map
	for i in range(5):
		var unit := UnitScene.instantiate()
		unit.global_position = Vector2(2500 + i * 50, 2500)
		unit.team = 1
		$Entities.add_child(unit)

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
		_:
			scene = UnitScene
	_spawn_unit(scene, building.rally_point, building.team)

func _spawn_unit(scene: PackedScene, pos: Vector2, team: int) -> CharacterBody2D:
	var unit := scene.instantiate()
	unit.global_position = pos
	unit.team = team
	$Entities.add_child(unit)
	return unit

func _spawn_resource_node(pos: Vector2, type: String, amount: int) -> void:
	var node := ResourceNodeScene.instantiate()
	node.global_position = pos
	node.resource_type = type
	node.amount = amount
	node.add_to_group("resources")
	$Entities.add_child(node)
