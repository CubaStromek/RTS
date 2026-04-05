extends Node
## Handles building placement mode. Player selects building type, then clicks to place.

signal build_mode_entered(building_type: String)
signal build_mode_exited()
signal building_placed(building: StaticBody2D)

const BUILDING_DEFS: Dictionary = {
	"barracks": {"gold": 150, "wood": 100, "scene": "res://scenes/buildings/Barracks.tscn"},
	"farm": {"gold": 50, "wood": 75, "scene": "res://scenes/buildings/Farm.tscn"},
	"tower": {"gold": 100, "wood": 80, "scene": "res://scenes/buildings/Tower.tscn"},
}

var is_building: bool = false
var current_type: String = ""
var _preview_pos: Vector2 = Vector2.ZERO
var _preview_node: Node2D = null

func enter_build_mode(building_type: String) -> void:
	if building_type not in BUILDING_DEFS:
		return
	var def: Dictionary = BUILDING_DEFS[building_type]
	if not _can_afford(def):
		return

	is_building = true
	current_type = building_type
	# Create preview ghost
	_preview_node = Node2D.new()
	_preview_node.set_script(preload("res://scenes/buildings/BuildPreview.gd"))
	_preview_node.building_type = building_type
	get_tree().current_scene.add_child(_preview_node)
	build_mode_entered.emit(building_type)

func cancel_build() -> void:
	is_building = false
	current_type = ""
	if _preview_node and is_instance_valid(_preview_node):
		_preview_node.queue_free()
		_preview_node = null
	build_mode_exited.emit()

func try_place(world_pos: Vector2) -> bool:
	if not is_building:
		return false
	var def: Dictionary = BUILDING_DEFS[current_type]
	if not _can_afford(def):
		cancel_build()
		return false

	# Check placement validity (not too close to other buildings)
	for building in get_tree().get_nodes_in_group("buildings"):
		if world_pos.distance_to(building.global_position) < 80.0:
			return false

	# Spend resources
	if not ResourceSystem.spend_resource("gold", def["gold"]):
		return false
	if not ResourceSystem.spend_resource("wood", def["wood"]):
		ResourceSystem.add_resource("gold", def["gold"])
		return false

	# Place building
	var scene: PackedScene = load(def["scene"])
	var building: StaticBody2D = scene.instantiate()
	building.global_position = world_pos
	building.team = 0
	building.add_to_group("buildings")
	if building.has_signal("unit_trained"):
		var main := get_tree().current_scene
		if main.has_method("_on_unit_trained"):
			building.unit_trained.connect(main._on_unit_trained)
	if current_type == "farm":
		ResourceSystem.add_population_cap(5)

	get_tree().current_scene.get_node("Entities").add_child(building)
	building_placed.emit(building)

	var snd := get_node_or_null("/root/SoundSystem")
	if snd:
		snd.play("build")

	cancel_build()
	return true

func _can_afford(def: Dictionary) -> bool:
	return ResourceSystem.get_resource("gold") >= def["gold"] and ResourceSystem.get_resource("wood") >= def["wood"]

func _input(event: InputEvent) -> void:
	if not is_building:
		return

	if event is InputEventMouseMotion:
		var camera := get_viewport().get_camera_2d()
		if camera and _preview_node:
			_preview_node.global_position = camera.get_global_mouse_position()

	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var camera := get_viewport().get_camera_2d()
			if camera:
				var pos := camera.get_global_mouse_position()
				try_place(pos)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_build()
			get_viewport().set_input_as_handled()

	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			cancel_build()
			get_viewport().set_input_as_handled()
