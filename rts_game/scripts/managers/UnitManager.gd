extends Node
## Tracks all living units in the game.

var all_units: Array[CharacterBody2D] = []

func register_unit(unit: CharacterBody2D) -> void:
	if unit not in all_units:
		all_units.append(unit)

func unregister_unit(unit: CharacterBody2D) -> void:
	all_units.erase(unit)

func get_units_in_rect(rect: Rect2) -> Array[CharacterBody2D]:
	var result: Array[CharacterBody2D] = []
	for unit in all_units:
		if rect.has_point(unit.global_position):
			result.append(unit)
	return result
