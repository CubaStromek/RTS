extends Node2D
## Root scene — entry point for the game. Spawns test units for Phase 1.

const UnitScene := preload("res://scenes/units/Unit.tscn")
const SPAWN_COUNT: int = 5

func _ready() -> void:
	print("Medieval RTS started!")
	_setup_selection_box_style()
	_spawn_test_units()

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

func _spawn_test_units() -> void:
	for i in range(SPAWN_COUNT):
		var unit := UnitScene.instantiate()
		unit.global_position = Vector2(400 + i * 60, 400)
		add_child(unit)
