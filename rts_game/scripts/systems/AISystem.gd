extends Node
## Simple AI opponent — spawns waves of enemies that attack the player base.

const WAVE_INTERVAL: float = 60.0  # Seconds between waves
const UNITS_PER_WAVE_BASE: int = 3
const UNITS_PER_WAVE_GROWTH: int = 2
const SPAWN_AREA := Vector2(3500, 3500)
const PLAYER_BASE := Vector2(500, 500)

var UnitScene: PackedScene = preload("res://scenes/units/Unit.tscn")
var ArcherScene: PackedScene = preload("res://scenes/units/Archer.tscn")

var wave_number: int = 0
var _wave_timer: float = WAVE_INTERVAL
var ai_units: Array[CharacterBody2D] = []

func _process(delta: float) -> void:
	_wave_timer -= delta
	if _wave_timer <= 0.0:
		_spawn_wave()
		_wave_timer = WAVE_INTERVAL

	# Clean up dead references
	ai_units = ai_units.filter(func(u: CharacterBody2D) -> bool: return is_instance_valid(u))

	# Command idle AI units to attack player base
	for unit in ai_units:
		if unit.attack_target == null and unit.velocity.length() < 1.0:
			# Find nearest player unit or building to attack
			var target := _find_nearest_player_target(unit.global_position)
			if target:
				unit.attack_unit(target)
			else:
				unit.move_to(PLAYER_BASE + Vector2(randf_range(-100, 100), randf_range(-100, 100)))

func _spawn_wave() -> void:
	wave_number += 1
	var count: int = UNITS_PER_WAVE_BASE + wave_number * UNITS_PER_WAVE_GROWTH
	var entities: Node2D = get_tree().current_scene.get_node("Entities")

	for i in range(count):
		var scene: PackedScene = UnitScene if randf() > 0.4 else ArcherScene
		var unit: CharacterBody2D = scene.instantiate()
		unit.global_position = SPAWN_AREA + Vector2(randf_range(-80, 80), randf_range(-80, 80))
		unit.team = 1
		entities.add_child(unit)
		ai_units.append(unit)
		# Send them toward the player
		unit.move_to(PLAYER_BASE + Vector2(randf_range(-150, 150), randf_range(-150, 150)))

	print("AI Wave %d: %d units spawned" % [wave_number, count])

func _find_nearest_player_target(from_pos: Vector2) -> CharacterBody2D:
	var closest: CharacterBody2D = null
	var closest_dist := INF
	for unit in UnitManager.all_units:
		if unit.team == 0:
			var dist := from_pos.distance_to(unit.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = unit
	return closest
