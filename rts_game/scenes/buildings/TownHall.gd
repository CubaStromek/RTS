extends "res://scenes/buildings/Building.gd"
## Town Hall — trains workers.

const WORKER_COST_GOLD: int = 50
const WORKER_COST_WOOD: int = 25
const WORKER_TRAIN_TIME: float = 8.0

const TOWNHALL_SIZE := Vector2(80, 80)

func _ready() -> void:
	super._ready()
	building_name = "Town Hall"
	building_color = Color(0.4, 0.4, 0.55)
	max_hp = 1000
	hp = max_hp

func _draw() -> void:
	var rect := Rect2(-TOWNHALL_SIZE / 2.0, TOWNHALL_SIZE)
	draw_rect(rect, building_color)
	if is_selected:
		draw_rect(rect, Color(0.0, 1.0, 0.0, 0.4), false, 2.0)
		draw_line(Vector2.ZERO, rally_point - global_position, Color(0.0, 1.0, 0.0, 0.3), 1.0)
	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := -52.0
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)

func train_worker() -> bool:
	return queue_unit("worker", WORKER_COST_GOLD, WORKER_COST_WOOD, WORKER_TRAIN_TIME)
