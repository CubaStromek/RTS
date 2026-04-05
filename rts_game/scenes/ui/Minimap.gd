extends Control
## Minimap — shows overhead view with click-to-move-camera support.

const MAP_SIZE := Vector2(4000, 4000)
const MINIMAP_SIZE := Vector2(200, 200)
const BG_COLOR := Color(0.1, 0.2, 0.1)
const FRIENDLY_UNIT_COLOR := Color(0.2, 0.5, 1.0)
const ENEMY_UNIT_COLOR := Color(1.0, 0.2, 0.2)
const BUILDING_COLOR := Color(0.8, 0.7, 0.3)
const RESOURCE_COLOR := Color(0.3, 0.8, 0.3)
const CAMERA_RECT_COLOR := Color(1.0, 1.0, 1.0, 0.6)

var fog_system: Node2D = null
var _is_dragging: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = MINIMAP_SIZE
	size = MINIMAP_SIZE

func _process(_delta: float) -> void:
	if fog_system == null:
		var main := get_tree().current_scene
		if main:
			fog_system = main.get_node_or_null("FogOfWar")
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_move_camera_to(event.position)
				get_viewport().set_input_as_handled()
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		_move_camera_to(event.position)
		get_viewport().set_input_as_handled()

func _move_camera_to(minimap_pos: Vector2) -> void:
	var world_pos := _minimap_to_world(minimap_pos)
	var camera := get_viewport().get_camera_2d()
	if camera:
		camera.position = world_pos

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, MINIMAP_SIZE), BG_COLOR)

	# Units
	for unit in UnitManager.all_units:
		if unit.team != 0 and fog_system and not fog_system.is_visible_at(unit.global_position):
			continue
		var pos := _world_to_minimap(unit.global_position)
		var color := FRIENDLY_UNIT_COLOR if unit.team == 0 else ENEMY_UNIT_COLOR
		draw_circle(pos, 2.0, color)

	# Buildings
	for building in get_tree().get_nodes_in_group("buildings"):
		var pos := _world_to_minimap(building.global_position)
		draw_rect(Rect2(pos - Vector2(3, 3), Vector2(6, 6)), BUILDING_COLOR)

	# Resources
	for res_node in get_tree().get_nodes_in_group("resources"):
		if fog_system and not fog_system.is_explored_at(res_node.global_position):
			continue
		var pos := _world_to_minimap(res_node.global_position)
		draw_circle(pos, 1.5, RESOURCE_COLOR)

	# Camera viewport rect
	var camera := get_viewport().get_camera_2d()
	if camera:
		var vp_size := get_viewport().get_visible_rect().size / camera.zoom
		var cam_top_left := camera.global_position - vp_size / 2.0
		var rect_pos := _world_to_minimap(cam_top_left)
		var rect_size := vp_size / MAP_SIZE * MINIMAP_SIZE
		draw_rect(Rect2(rect_pos, rect_size), CAMERA_RECT_COLOR, false, 1.0)

	# Border
	draw_rect(Rect2(Vector2.ZERO, MINIMAP_SIZE), Color(0.5, 0.5, 0.5), false, 1.0)

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	return (world_pos / MAP_SIZE * MINIMAP_SIZE).clamp(Vector2.ZERO, MINIMAP_SIZE)

func _minimap_to_world(minimap_pos: Vector2) -> Vector2:
	return minimap_pos / MINIMAP_SIZE * MAP_SIZE
