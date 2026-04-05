extends Node
## Processes commands issued to units (move, attack, harvest).

signal command_issued(units: Array[CharacterBody2D], command: Dictionary)

func issue_move(units: Array[CharacterBody2D], target_pos: Vector2) -> void:
	var count := units.size()
	for i in range(count):
		var offset := _get_formation_offset(i, count)
		units[i].move_to(target_pos + offset)
	command_issued.emit(units, {"type": "move", "target": target_pos})

func issue_attack(units: Array[CharacterBody2D], target: CharacterBody2D) -> void:
	for unit in units:
		unit.attack_unit(target)
	command_issued.emit(units, {"type": "attack", "target": target})

func issue_harvest(workers: Array[CharacterBody2D], resource_node: StaticBody2D) -> void:
	for unit in workers:
		if unit.has_method("harvest_resource"):
			unit.harvest_resource(resource_node)
	command_issued.emit(workers, {"type": "harvest", "target": resource_node})

func _get_formation_offset(index: int, total: int) -> Vector2:
	if total <= 1:
		return Vector2.ZERO
	var cols := ceili(sqrt(float(total)))
	@warning_ignore("integer_division")
	var row := index / cols
	var col := index % cols
	var spacing := 40.0
	var offset_x := (col - (cols - 1) / 2.0) * spacing
	var offset_y := (row - (ceili(float(total) / cols) - 1) / 2.0) * spacing
	return Vector2(offset_x, offset_y)
