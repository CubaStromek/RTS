extends Node
## Processes commands issued to units (move, attack, etc.).

signal command_issued(units: Array[CharacterBody2D], command: Dictionary)

func issue_move(units: Array[CharacterBody2D], target_pos: Vector2) -> void:
	var count := units.size()
	for i in range(count):
		var offset := _get_formation_offset(i, count)
		units[i].move_to(target_pos + offset)

	command_issued.emit(units, {"type": "move", "target": target_pos})

func _get_formation_offset(index: int, total: int) -> Vector2:
	if total <= 1:
		return Vector2.ZERO

	# Arrange in a grid-like formation
	var cols := ceili(sqrt(float(total)))
	var row := index / cols
	var col := index % cols
	var spacing := 40.0

	# Center the formation
	var offset_x := (col - (cols - 1) / 2.0) * spacing
	var offset_y := (row - (ceili(float(total) / cols) - 1) / 2.0) * spacing
	return Vector2(offset_x, offset_y)
