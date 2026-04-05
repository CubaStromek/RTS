extends CharacterBody2D
## Base unit with selection, movement, combat, and placeholder visuals.

signal selected(unit: CharacterBody2D)
signal deselected(unit: CharacterBody2D)
signal died(unit: CharacterBody2D)

const SELECTION_RING_COLOR := Color(0.0, 1.0, 0.0, 0.8)
const ENEMY_COLOR := Color(0.85, 0.15, 0.15)
const FRIENDLY_COLOR := Color(0.2, 0.4, 0.9)
const UNIT_RADIUS: float = 14.0
const HP_BAR_WIDTH: float = 30.0
const HP_BAR_HEIGHT: float = 4.0
const HP_BAR_OFFSET_Y: float = -22.0

@export var move_speed: float = 200.0
@export var max_hp: int = 100
@export var attack_damage: int = 10
@export var attack_range: float = 60.0
@export var attack_cooldown: float = 1.0
@export var aggro_range: float = 150.0
@export var team: int = 0
@export var unit_type: String = "soldier"

var hp: int
var is_selected: bool = false
var attack_target: CharacterBody2D = null
var _attack_timer: float = 0.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	hp = max_hp
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = true
	nav_agent.radius = UNIT_RADIUS
	UnitManager.register_unit(self)

func _exit_tree() -> void:
	UnitManager.unregister_unit(self)

func _physics_process(delta: float) -> void:
	_attack_timer = max(0.0, _attack_timer - delta)

	# Auto-aggro: find nearby enemies if idle
	if attack_target == null or not is_instance_valid(attack_target):
		attack_target = null
		_find_aggro_target()

	# If we have a target, chase or attack
	if attack_target and is_instance_valid(attack_target):
		var dist := global_position.distance_to(attack_target.global_position)
		if dist <= attack_range:
			# In range — stop and attack
			velocity = Vector2.ZERO
			if _attack_timer <= 0.0:
				_perform_attack()
			return
		else:
			# Chase the target
			nav_agent.target_position = attack_target.global_position

	# Navigation movement
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_pos := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)
	velocity = direction * move_speed
	move_and_slide()

func _draw() -> void:
	# Selection ring
	if is_selected:
		draw_arc(Vector2.ZERO, UNIT_RADIUS + 4, 0, TAU, 32, SELECTION_RING_COLOR, 2.0)
	# Unit body
	var color := FRIENDLY_COLOR if team == 0 else ENEMY_COLOR
	draw_circle(Vector2.ZERO, UNIT_RADIUS, color)

	# HP bar (only if damaged)
	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := HP_BAR_OFFSET_Y
		# Background
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		# Fill
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)

func move_to(target_pos: Vector2) -> void:
	attack_target = null
	nav_agent.target_position = target_pos

func attack_unit(target: CharacterBody2D) -> void:
	attack_target = target

func take_damage(amount: int, attacker: CharacterBody2D) -> void:
	hp -= amount
	queue_redraw()
	if hp <= 0:
		_die()
	elif attack_target == null:
		# Retaliate if idle
		attack_target = attacker

func select() -> void:
	is_selected = true
	queue_redraw()
	selected.emit(self)
	if has_node("/root/SoundSystem"):
		SoundSystem.play("select")

func deselect() -> void:
	is_selected = false
	queue_redraw()
	deselected.emit(self)

func _perform_attack() -> void:
	_attack_timer = attack_cooldown
	if attack_target and is_instance_valid(attack_target) and attack_target.has_method("take_damage"):
		attack_target.take_damage(attack_damage, self)
		if has_node("/root/SoundSystem"):
			SoundSystem.play("attack")

func _find_aggro_target() -> void:
	var closest_dist := aggro_range
	for unit in UnitManager.all_units:
		if unit == self or unit.team == team:
			continue
		var dist := global_position.distance_to(unit.global_position)
		if dist < closest_dist:
			closest_dist = dist
			attack_target = unit

func _die() -> void:
	died.emit(self)
	if has_node("/root/SoundSystem"):
		SoundSystem.play("death")
	# Remove from selection
	if is_selected:
		SelectionSystem.selected_units.erase(self)
	queue_free()
