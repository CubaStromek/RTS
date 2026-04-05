extends "res://scenes/units/Unit.gd"
## Knight — heavy melee unit with high HP and damage, but slow.

const KNIGHT_COLOR := Color(0.8, 0.75, 0.2)
const KNIGHT_ENEMY_COLOR := Color(0.7, 0.2, 0.1)

func _ready() -> void:
	super._ready()
	unit_type = "knight"
	max_hp = 200
	hp = max_hp
	attack_damage = 25
	attack_range = 50.0
	attack_cooldown = 1.8
	aggro_range = 120.0
	move_speed = 120.0

func _draw() -> void:
	if is_selected:
		draw_arc(Vector2.ZERO, UNIT_RADIUS + 6, 0, TAU, 32, SELECTION_RING_COLOR, 2.0)
	# Square shape for knight (bigger)
	var color: Color = KNIGHT_COLOR if team == 0 else KNIGHT_ENEMY_COLOR
	var size := UNIT_RADIUS * 1.3
	draw_rect(Rect2(-size, -size, size * 2, size * 2), color)

	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := -28.0
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)
