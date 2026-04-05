extends StaticBody2D
## Harvestable resource node (gold mine or tree).

@export var resource_type: String = "gold"  # "gold" or "wood"
@export var amount: int = 500
@export var harvest_rate: int = 5  # Per harvest tick

const NODE_RADIUS: float = 20.0
const GOLD_COLOR := Color(1.0, 0.84, 0.0)
const WOOD_COLOR := Color(0.3, 0.6, 0.15)

func _ready() -> void:
	collision_layer = 4

func _draw() -> void:
	var color := GOLD_COLOR if resource_type == "gold" else WOOD_COLOR
	if resource_type == "gold":
		# Diamond shape for gold
		var points := PackedVector2Array([
			Vector2(0, -NODE_RADIUS),
			Vector2(NODE_RADIUS, 0),
			Vector2(0, NODE_RADIUS),
			Vector2(-NODE_RADIUS, 0),
		])
		draw_colored_polygon(points, color)
	else:
		# Tree shape (circle + trunk)
		draw_circle(Vector2(0, -8), 16, color)
		draw_rect(Rect2(-4, 4, 8, 14), Color(0.45, 0.28, 0.1))

func harvest(harvest_amount: int) -> int:
	var taken := mini(harvest_amount, amount)
	amount -= taken
	if amount <= 0:
		queue_free()
	return taken
