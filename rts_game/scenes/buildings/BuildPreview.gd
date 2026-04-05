extends Node2D
## Ghost preview of building being placed. Shows green/red based on validity.

var building_type: String = ""
const PREVIEW_SIZE := Vector2(64, 64)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var valid := _is_valid_placement()
	var color := Color(0.0, 1.0, 0.0, 0.3) if valid else Color(1.0, 0.0, 0.0, 0.3)
	var border := Color(0.0, 1.0, 0.0, 0.8) if valid else Color(1.0, 0.0, 0.0, 0.8)
	draw_rect(Rect2(-PREVIEW_SIZE / 2.0, PREVIEW_SIZE), color)
	draw_rect(Rect2(-PREVIEW_SIZE / 2.0, PREVIEW_SIZE), border, false, 2.0)

	# Label
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-28, 5), building_type.capitalize(), HORIZONTAL_ALIGNMENT_CENTER, 56, 12, Color.WHITE)

func _is_valid_placement() -> bool:
	for building in get_tree().get_nodes_in_group("buildings"):
		if global_position.distance_to(building.global_position) < 80.0:
			return false
	return true
