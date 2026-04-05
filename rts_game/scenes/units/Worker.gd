extends "res://scenes/units/Unit.gd"
## Worker unit — can harvest resources and return them to Town Hall.

enum WorkerState { IDLE, MOVING_TO_RESOURCE, HARVESTING, RETURNING }

const HARVEST_INTERVAL: float = 1.0
const CARRY_CAPACITY: int = 20
const WORKER_COLOR := Color(0.2, 0.7, 0.3)
const RETURN_DISTANCE: float = 50.0

var state: WorkerState = WorkerState.IDLE
var target_resource: StaticBody2D = null
var return_building: StaticBody2D = null
var carried_amount: int = 0
var carried_type: String = ""
var _harvest_timer: float = 0.0

func _ready() -> void:
	super._ready()
	unit_type = "worker"
	attack_damage = 3
	attack_range = 30.0
	move_speed = 160.0

func _physics_process(delta: float) -> void:
	match state:
		WorkerState.IDLE:
			super._physics_process(delta)
		WorkerState.MOVING_TO_RESOURCE:
			_move_to_resource(delta)
		WorkerState.HARVESTING:
			_do_harvest(delta)
		WorkerState.RETURNING:
			_do_return(delta)

func _draw() -> void:
	# Selection ring
	if is_selected:
		draw_arc(Vector2.ZERO, UNIT_RADIUS + 4, 0, TAU, 32, SELECTION_RING_COLOR, 2.0)
	# Worker body
	var color := WORKER_COLOR if team == 0 else ENEMY_COLOR
	draw_circle(Vector2.ZERO, UNIT_RADIUS, color)

	# Carry indicator
	if carried_amount > 0:
		var carry_color := Color(1.0, 0.84, 0.0) if carried_type == "gold" else Color(0.45, 0.28, 0.1)
		draw_circle(Vector2(0, -6), 4, carry_color)

	# HP bar
	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := HP_BAR_OFFSET_Y
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)

func harvest_resource(resource_node: StaticBody2D) -> void:
	attack_target = null
	target_resource = resource_node
	state = WorkerState.MOVING_TO_RESOURCE
	nav_agent.target_position = resource_node.global_position

func move_to(target_pos: Vector2) -> void:
	# Cancel harvesting on manual move command
	state = WorkerState.IDLE
	target_resource = null
	super.move_to(target_pos)

func _move_to_resource(_delta: float) -> void:
	if not is_instance_valid(target_resource):
		state = WorkerState.IDLE
		return

	nav_agent.target_position = target_resource.global_position
	if global_position.distance_to(target_resource.global_position) < 30.0:
		state = WorkerState.HARVESTING
		velocity = Vector2.ZERO
		_harvest_timer = HARVEST_INTERVAL
		carried_type = target_resource.resource_type
		return

	# Standard movement
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * move_speed
		move_and_slide()

func _do_harvest(delta: float) -> void:
	if not is_instance_valid(target_resource):
		if carried_amount > 0:
			_start_returning()
		else:
			state = WorkerState.IDLE
		return

	velocity = Vector2.ZERO
	_harvest_timer -= delta
	if _harvest_timer <= 0.0:
		_harvest_timer = HARVEST_INTERVAL
		var taken: int = target_resource.harvest(target_resource.harvest_rate)
		carried_amount += taken
		queue_redraw()
		if carried_amount >= CARRY_CAPACITY:
			_start_returning()

func _start_returning() -> void:
	state = WorkerState.RETURNING
	# Find nearest Town Hall
	return_building = _find_nearest_townhall()
	if return_building and is_instance_valid(return_building):
		nav_agent.target_position = return_building.global_position
	else:
		# No town hall — just deposit instantly
		ResourceSystem.add_resource(carried_type, carried_amount)
		carried_amount = 0
		state = WorkerState.IDLE

func _do_return(_delta: float) -> void:
	if not return_building or not is_instance_valid(return_building):
		ResourceSystem.add_resource(carried_type, carried_amount)
		carried_amount = 0
		state = WorkerState.IDLE
		return

	if global_position.distance_to(return_building.global_position) < RETURN_DISTANCE:
		# Deposit resources
		ResourceSystem.add_resource(carried_type, carried_amount)
		carried_amount = 0
		queue_redraw()
		# Go back to resource if it still exists
		if target_resource and is_instance_valid(target_resource):
			state = WorkerState.MOVING_TO_RESOURCE
			nav_agent.target_position = target_resource.global_position
		else:
			state = WorkerState.IDLE
		return

	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * move_speed
		move_and_slide()

func _find_nearest_townhall() -> StaticBody2D:
	var closest: StaticBody2D = null
	var closest_dist := INF
	for node in get_tree().get_nodes_in_group("townhalls"):
		var dist := global_position.distance_to(node.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = node
	return closest
