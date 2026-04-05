extends Node2D
## Placeholder game map — draws a green terrain rectangle.

const MAP_SIZE := Vector2(4000, 4000)
const GRASS_COLOR := Color(0.2, 0.55, 0.2)
const GRID_COLOR := Color(0.25, 0.6, 0.25, 0.3)
const GRID_STEP: int = 64

func _draw() -> void:
	# Green terrain background
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), GRASS_COLOR)

	# Subtle grid overlay
	for x in range(0, int(MAP_SIZE.x) + 1, GRID_STEP):
		draw_line(Vector2(x, 0), Vector2(x, MAP_SIZE.y), GRID_COLOR)
	for y in range(0, int(MAP_SIZE.y) + 1, GRID_STEP):
		draw_line(Vector2(0, y), Vector2(MAP_SIZE.x, y), GRID_COLOR)
