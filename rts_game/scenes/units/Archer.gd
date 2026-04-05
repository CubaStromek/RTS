extends Unit
## Archer — ranged unit with longer attack range but lower HP.

const ARCHER_COLOR := Color(0.6, 0.3, 0.7)
const ARCHER_ENEMY_COLOR := Color(0.8, 0.3, 0.5)

func _ready() -> void:
	super._ready()
	unit_type = "archer"
	max_hp = 60
	hp = max_hp
	attack_damage = 15
	attack_range = 150.0
	attack_cooldown = 1.5
	aggro_range = 200.0
	move_speed = 180.0

func _draw() -> void:
	if is_selected:
		draw_arc(Vector2.ZERO, UNIT_RADIUS + 4, 0, TAU, 32, SELECTION_RING_COLOR, 2.0)
	# Triangle shape for archer
	var color: Color = ARCHER_COLOR if team == 0 else ARCHER_ENEMY_COLOR
	var points := PackedVector2Array([
		Vector2(0, -UNIT_RADIUS),
		Vector2(UNIT_RADIUS, UNIT_RADIUS * 0.7),
		Vector2(-UNIT_RADIUS, UNIT_RADIUS * 0.7),
	])
	draw_colored_polygon(points, color)

	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := HP_BAR_OFFSET_Y
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)
