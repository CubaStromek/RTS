extends BuildingBase
## Defense Tower — automatically attacks nearby enemies.

const TOWER_RANGE: float = 200.0
const TOWER_DAMAGE: int = 20
const TOWER_COOLDOWN: float = 1.5
const TOWER_COLOR_BASE := Color(0.4, 0.4, 0.5)

var _attack_timer: float = 0.0
var _current_target: CharacterBody2D = null

const AttackLineScript := preload("res://scenes/effects/AttackLine.gd")

func _ready() -> void:
	super._ready()
	building_name = "Tower"
	building_color = TOWER_COLOR_BASE
	max_hp = 400
	hp = max_hp

func _process(delta: float) -> void:
	super._process(delta)
	_attack_timer = max(0.0, _attack_timer - delta)

	# Find target
	if _current_target == null or not is_instance_valid(_current_target):
		_current_target = _find_target()

	if _current_target and is_instance_valid(_current_target):
		var dist := global_position.distance_to(_current_target.global_position)
		if dist > TOWER_RANGE:
			_current_target = null
		elif _attack_timer <= 0.0:
			_attack_timer = TOWER_COOLDOWN
			_current_target.take_damage(TOWER_DAMAGE, null)
			_spawn_attack_line(global_position, _current_target.global_position)
			var snd := get_node_or_null("/root/SoundSystem")
			if snd:
				snd.play("attack")

func _draw() -> void:
	# Tower base (circle)
	draw_circle(Vector2.ZERO, 24, building_color)
	# Tower top (darker inner circle)
	draw_circle(Vector2.ZERO, 12, building_color.darkened(0.3))

	# Range indicator when selected
	if is_selected:
		draw_arc(Vector2.ZERO, TOWER_RANGE, 0, TAU, 48, Color(1.0, 0.3, 0.3, 0.2), 1.0)
		draw_arc(Vector2.ZERO, 26, 0, TAU, 24, Color(0.0, 1.0, 0.0, 0.4), 2.0)

	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := -36.0
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)

func _find_target() -> CharacterBody2D:
	var closest: CharacterBody2D = null
	var closest_dist := TOWER_RANGE
	for unit in UnitManager.all_units:
		if unit.team == team:
			continue
		var dist := global_position.distance_to(unit.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = unit
	return closest

func _spawn_attack_line(from: Vector2, to: Vector2) -> void:
	var line := Node2D.new()
	line.set_script(AttackLineScript)
	get_tree().current_scene.add_child(line)
	line.setup(from, to, Color(0.5, 0.5, 1.0))
