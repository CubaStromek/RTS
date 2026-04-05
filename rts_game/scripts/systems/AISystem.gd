extends Node
## Simple AI opponent — spawns waves of enemies that attack the player base.

const WAVE_INTERVAL: float = 60.0
const UNITS_PER_WAVE_BASE: int = 3
const UNITS_PER_WAVE_GROWTH: int = 2
const MAX_WAVES: int = 5
const SPAWN_AREA := Vector2(3500, 3500)
const PLAYER_BASE := Vector2(500, 500)

var UnitScene: PackedScene = preload("res://scenes/units/Unit.tscn")
var ArcherScene: PackedScene = preload("res://scenes/units/Archer.tscn")
var KnightScene: PackedScene = preload("res://scenes/units/Knight.tscn")

var wave_number: int = 0
var _wave_timer: float = WAVE_INTERVAL
var ai_units: Array[CharacterBody2D] = []

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	if wave_number < MAX_WAVES:
		_wave_timer -= delta
		if _wave_timer <= 0.0:
			_spawn_wave()
			_wave_timer = WAVE_INTERVAL

	# Clean up dead references
	var alive: Array[CharacterBody2D] = []
	for u in ai_units:
		if is_instance_valid(u):
			alive.append(u)
	ai_units = alive

	# Command idle AI units to attack player base
	for unit in ai_units:
		if unit.attack_target == null and unit.velocity.length() < 1.0:
			var target := _find_nearest_player_target(unit.global_position)
			if target:
				unit.attack_unit(target)
			else:
				unit.move_to(PLAYER_BASE + Vector2(randf_range(-100, 100), randf_range(-100, 100)))

func _spawn_wave() -> void:
	wave_number += 1
	GameManager.register_wave_survived()
	var count: int = UNITS_PER_WAVE_BASE + wave_number * UNITS_PER_WAVE_GROWTH
	var entities: Node2D = get_tree().current_scene.get_node("Entities")

	for i in range(count):
		var roll := randf()
		var scene: PackedScene
		if wave_number >= 3 and roll < 0.2:
			scene = KnightScene
		elif roll < 0.5:
			scene = ArcherScene
		else:
			scene = UnitScene

		var unit: CharacterBody2D = scene.instantiate()
		unit.global_position = SPAWN_AREA + Vector2(randf_range(-80, 80), randf_range(-80, 80))
		unit.team = 1
		entities.add_child(unit)
		ai_units.append(unit)
		unit.move_to(PLAYER_BASE + Vector2(randf_range(-150, 150), randf_range(-150, 150)))

	print("AI Wave %d/%d: %d units spawned" % [wave_number, MAX_WAVES, count])

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
