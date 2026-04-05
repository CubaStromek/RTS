extends Node
## AI opponent — enemy base with production, counter-strategy, and multi-pronged attacks.

const WAVE_INTERVAL: float = 60.0
const UNITS_PER_WAVE_BASE: int = 3
const UNITS_PER_WAVE_GROWTH: int = 2
const MAX_WAVES: int = 5
const SPAWN_AREA := Vector2(3500, 3500)
const PLAYER_BASE := Vector2(500, 500)

var UnitScene: PackedScene = preload("res://scenes/units/Unit.tscn")
var ArcherScene: PackedScene = preload("res://scenes/units/Archer.tscn")
var KnightScene: PackedScene = preload("res://scenes/units/Knight.tscn")
var TownHallScene: PackedScene = preload("res://scenes/buildings/TownHall.tscn")
var BarracksScene: PackedScene = preload("res://scenes/buildings/Barracks.tscn")

var wave_number: int = 0
var _wave_timer: float = WAVE_INTERVAL
var ai_units: Array[CharacterBody2D] = []
var _ai_base_spawned: bool = false
var _production_timer: float = 8.0

# Counter-strategy tracking
var _player_soldiers: int = 0
var _player_archers: int = 0
var _player_knights: int = 0

func _ready() -> void:
	# Spawn AI base
	call_deferred("_spawn_ai_base")

func _spawn_ai_base() -> void:
	var entities: Node2D = get_tree().current_scene.get_node("Entities")

	# AI Town Hall
	var town_hall := TownHallScene.instantiate()
	town_hall.global_position = SPAWN_AREA
	town_hall.team = 1
	town_hall.add_to_group("buildings")
	entities.add_child(town_hall)

	# AI Barracks
	var barracks := BarracksScene.instantiate()
	barracks.global_position = SPAWN_AREA + Vector2(-100, 0)
	barracks.team = 1
	barracks.add_to_group("buildings")
	entities.add_child(barracks)

	_ai_base_spawned = true

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if GameManager.game_mode == GameManager.GameMode.SANDBOX:
		return

	if wave_number < MAX_WAVES:
		_wave_timer -= delta
		if _wave_timer <= 0.0:
			_spawn_wave()
			_wave_timer = WAVE_INTERVAL

	# AI continuous production between waves
	_production_timer -= delta
	if _production_timer <= 0.0:
		_production_timer = 12.0
		_produce_unit()

	# Clean up dead references
	var alive: Array[CharacterBody2D] = []
	for u in ai_units:
		if is_instance_valid(u):
			alive.append(u)
	ai_units = alive

	# Analyze player composition for counter-strategy
	_analyze_player_composition()

	# Command idle AI units
	for unit in ai_units:
		if unit.attack_target == null and unit.velocity.length() < 1.0:
			var target := _find_priority_target(unit)
			if target:
				unit.attack_unit(target)
			else:
				unit.move_to(PLAYER_BASE + Vector2(randf_range(-100, 100), randf_range(-100, 100)))

func _analyze_player_composition() -> void:
	_player_soldiers = 0
	_player_archers = 0
	_player_knights = 0
	for unit in UnitManager.all_units:
		if unit.team == 0:
			match unit.unit_type:
				"soldier":
					_player_soldiers += 1
				"archer":
					_player_archers += 1
				"knight":
					_player_knights += 1

func _get_counter_scene() -> PackedScene:
	# Counter-strategy: produce what beats the player's majority
	if _player_archers > _player_soldiers and _player_archers > _player_knights:
		return UnitScene  # Soldiers beat Archers
	elif _player_soldiers > _player_archers and _player_soldiers > _player_knights:
		return KnightScene  # Knights beat Soldiers
	elif _player_knights > 0:
		return ArcherScene  # Archers beat Knights
	else:
		# Default mix
		var roll := randf()
		if roll < 0.4:
			return UnitScene
		elif roll < 0.7:
			return ArcherScene
		else:
			return KnightScene

func _produce_unit() -> void:
	if ai_units.size() >= 20:
		return
	var scene := _get_counter_scene()
	var entities: Node2D = get_tree().current_scene.get_node("Entities")
	var unit: CharacterBody2D = scene.instantiate()
	unit.global_position = SPAWN_AREA + Vector2(randf_range(-60, 60), randf_range(40, 80))
	unit.team = 1
	entities.add_child(unit)
	ai_units.append(unit)

func _spawn_wave() -> void:
	wave_number += 1
	GameManager.register_wave_survived()
	var count: int = UNITS_PER_WAVE_BASE + wave_number * UNITS_PER_WAVE_GROWTH
	var entities: Node2D = get_tree().current_scene.get_node("Entities")

	# Multi-pronged attack: 60% main force, 40% flank
	var main_count: int = int(count * 0.6)
	var flank_count := count - main_count
	var flank_offset := Vector2(randf_range(-400, 400), randf_range(-400, 400))

	for i in range(count):
		var scene: PackedScene = _get_counter_scene()
		# Some randomness
		if wave_number >= 3 and randf() < 0.25:
			scene = KnightScene

		var unit: CharacterBody2D = scene.instantiate()
		if i < main_count:
			unit.global_position = SPAWN_AREA + Vector2(randf_range(-80, 80), randf_range(-80, 80))
			unit.move_to(PLAYER_BASE + Vector2(randf_range(-100, 100), randf_range(-100, 100)))
		else:
			# Flank group approaches from a different angle
			unit.global_position = SPAWN_AREA + flank_offset + Vector2(randf_range(-40, 40), randf_range(-40, 40))
			var flank_target := PLAYER_BASE + Vector2(randf_range(-200, 200), randf_range(-200, 200))
			unit.move_to(flank_target)

		unit.team = 1
		entities.add_child(unit)
		ai_units.append(unit)

	print("AI Wave %d/%d: %d units (main: %d, flank: %d)" % [wave_number, MAX_WAVES, count, main_count, flank_count])

	# Play wave warning sound
	var snd := get_node_or_null("/root/SoundSystem")
	if snd:
		snd.play("wave_incoming")
	var notify := get_node_or_null("/root/NotificationSystem")
	if notify:
		notify.notify("Wave %d incoming!" % wave_number, Color(1.0, 0.4, 0.2))

func _find_priority_target(ai_unit: CharacterBody2D) -> CharacterBody2D:
	# Priority: Workers > Archers > Buildings > Other
	var best_target: CharacterBody2D = null
	var best_priority: int = 0
	var best_dist: float = INF

	for unit in UnitManager.all_units:
		if unit.team == 0:
			var priority: int
			match unit.unit_type:
				"worker":
					priority = 4
				"archer":
					priority = 3
				_:
					priority = 1
			var dist := ai_unit.global_position.distance_to(unit.global_position)
			if priority > best_priority or (priority == best_priority and dist < best_dist):
				best_priority = priority
				best_dist = dist
				best_target = unit

	return best_target
