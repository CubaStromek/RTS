extends BuildingBase
## Farm — provides +5 population cap. No production.

const FARM_SIZE := Vector2(48, 48)
const WHEAT_COLOR := Color(0.85, 0.75, 0.3)

func _ready() -> void:
	super._ready()
	building_name = "Farm"
	building_color = Color(0.55, 0.45, 0.2)
	max_hp = 200
	hp = max_hp

func _draw() -> void:
	var rect := Rect2(-FARM_SIZE / 2.0, FARM_SIZE)
	draw_rect(rect, building_color)
	# Wheat rows
	for i in range(3):
		var y: float = -16.0 + i * 12.0
		draw_line(Vector2(-18, y), Vector2(18, y), WHEAT_COLOR, 2.0)
	if is_selected:
		draw_rect(rect, Color(0.0, 1.0, 0.0, 0.4), false, 2.0)
	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := -34.0
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)
