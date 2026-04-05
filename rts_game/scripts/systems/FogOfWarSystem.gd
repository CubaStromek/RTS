extends Node2D
## Fog of War — renders darkness over unexplored/invisible areas.
## Uses a texture-based approach: each cell is unexplored (black), explored (dark), or visible (clear).

const MAP_SIZE := Vector2(4000, 4000)
const CELL_SIZE: int = 32
const SIGHT_RADIUS: int = 6  # In cells

enum FogState { UNEXPLORED, EXPLORED, VISIBLE }

var grid_width: int
var grid_height: int
var fog_grid: PackedByteArray
var _fog_image: Image
var _fog_texture: ImageTexture

func _ready() -> void:
	grid_width = ceili(MAP_SIZE.x / CELL_SIZE)
	grid_height = ceili(MAP_SIZE.y / CELL_SIZE)
	fog_grid = PackedByteArray()
	fog_grid.resize(grid_width * grid_height)
	fog_grid.fill(FogState.UNEXPLORED)

	_fog_image = Image.create(grid_width, grid_height, false, Image.FORMAT_RGBA8)
	_fog_image.fill(Color(0.0, 0.0, 0.0, 1.0))
	_fog_texture = ImageTexture.create_from_image(_fog_image)

	z_index = 100

func _process(_delta: float) -> void:
	_reset_visible()
	_reveal_around_units()
	_update_texture()
	queue_redraw()

func _reset_visible() -> void:
	for i in range(fog_grid.size()):
		if fog_grid[i] == FogState.VISIBLE:
			fog_grid[i] = FogState.EXPLORED

func _reveal_around_units() -> void:
	# Reveal around friendly units
	for unit in UnitManager.all_units:
		if unit.team == 0:
			_reveal_circle(unit.global_position)

	# Reveal around friendly buildings
	for building in get_tree().get_nodes_in_group("buildings"):
		if building.team == 0:
			_reveal_circle(building.global_position)

func _reveal_circle(world_pos: Vector2) -> void:
	var cx: int = int(world_pos.x / CELL_SIZE)
	var cy: int = int(world_pos.y / CELL_SIZE)
	var r2: int = SIGHT_RADIUS * SIGHT_RADIUS

	for dy in range(-SIGHT_RADIUS, SIGHT_RADIUS + 1):
		for dx in range(-SIGHT_RADIUS, SIGHT_RADIUS + 1):
			if dx * dx + dy * dy > r2:
				continue
			var gx: int = cx + dx
			var gy: int = cy + dy
			if gx >= 0 and gx < grid_width and gy >= 0 and gy < grid_height:
				fog_grid[gy * grid_width + gx] = FogState.VISIBLE

func _update_texture() -> void:
	for y in range(grid_height):
		for x in range(grid_width):
			var state: int = fog_grid[y * grid_width + x]
			var color: Color
			match state:
				FogState.UNEXPLORED:
					color = Color(0.0, 0.0, 0.0, 0.9)
				FogState.EXPLORED:
					color = Color(0.0, 0.0, 0.0, 0.55)
				FogState.VISIBLE:
					color = Color(0.0, 0.0, 0.0, 0.0)
			_fog_image.set_pixel(x, y, color)
	_fog_texture.update(_fog_image)

func _draw() -> void:
	draw_texture_rect(_fog_texture, Rect2(Vector2.ZERO, MAP_SIZE), false)

func is_visible_at(world_pos: Vector2) -> bool:
	var gx: int = int(world_pos.x / CELL_SIZE)
	var gy: int = int(world_pos.y / CELL_SIZE)
	if gx < 0 or gx >= grid_width or gy < 0 or gy >= grid_height:
		return false
	return fog_grid[gy * grid_width + gx] == FogState.VISIBLE

func is_explored_at(world_pos: Vector2) -> bool:
	var gx: int = int(world_pos.x / CELL_SIZE)
	var gy: int = int(world_pos.y / CELL_SIZE)
	if gx < 0 or gx >= grid_width or gy < 0 or gy >= grid_height:
		return false
	return fog_grid[gy * grid_width + gx] != FogState.UNEXPLORED
