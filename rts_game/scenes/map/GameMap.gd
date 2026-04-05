extends Node2D
## Game map — draws terrain with grass, dirt patches, and water features.

const MAP_SIZE := Vector2(4000, 4000)
const GRASS_COLOR := Color(0.22, 0.52, 0.22)
const GRASS_LIGHT := Color(0.26, 0.58, 0.26)
const DIRT_COLOR := Color(0.45, 0.35, 0.2)
const WATER_COLOR := Color(0.15, 0.3, 0.55)
const GRID_COLOR := Color(0.25, 0.55, 0.25, 0.15)
const GRID_STEP: int = 64

var _dirt_patches: Array[Dictionary] = []
var _water_areas: Array[Dictionary] = []
var _grass_spots: Array[Dictionary] = []

func _ready() -> void:
	# Generate random terrain features
	var rng := RandomNumberGenerator.new()
	rng.seed = 42  # Deterministic for consistency

	# Dirt patches (paths, clearings)
	for i in range(15):
		_dirt_patches.append({
			"pos": Vector2(rng.randf_range(200, 3800), rng.randf_range(200, 3800)),
			"size": Vector2(rng.randf_range(60, 200), rng.randf_range(40, 120)),
		})

	# Small ponds
	_water_areas.append({"pos": Vector2(1800, 800), "radius": 80.0})
	_water_areas.append({"pos": Vector2(2800, 1600), "radius": 60.0})
	_water_areas.append({"pos": Vector2(1200, 2800), "radius": 50.0})

	# Light grass variation spots
	for i in range(40):
		_grass_spots.append({
			"pos": Vector2(rng.randf_range(0, 4000), rng.randf_range(0, 4000)),
			"radius": rng.randf_range(30, 80),
		})

func _draw() -> void:
	# Base green terrain
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), GRASS_COLOR)

	# Light grass patches
	for spot in _grass_spots:
		draw_circle(spot["pos"], spot["radius"], GRASS_LIGHT)

	# Dirt patches
	for patch in _dirt_patches:
		var rect := Rect2(patch["pos"] - patch["size"] / 2.0, patch["size"])
		draw_rect(rect, DIRT_COLOR)

	# Water
	for water in _water_areas:
		draw_circle(water["pos"], water["radius"], WATER_COLOR)
		draw_arc(water["pos"], water["radius"], 0, TAU, 32, WATER_COLOR.lightened(0.2), 2.0)

	# Grid overlay
	for x in range(0, int(MAP_SIZE.x) + 1, GRID_STEP):
		draw_line(Vector2(x, 0), Vector2(x, MAP_SIZE.y), GRID_COLOR)
	for y in range(0, int(MAP_SIZE.y) + 1, GRID_STEP):
		draw_line(Vector2(0, y), Vector2(MAP_SIZE.x, y), GRID_COLOR)

	# Map border
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color(0.3, 0.2, 0.1), false, 4.0)
