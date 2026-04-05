extends CharacterBody2D
## Base unit with selection, movement via NavigationAgent2D, and placeholder visuals.

signal selected(unit: CharacterBody2D)
signal deselected(unit: CharacterBody2D)

const SELECTION_RING_COLOR := Color(0.0, 1.0, 0.0, 0.8)
const UNIT_COLOR := Color(0.2, 0.4, 0.9)
const UNIT_RADIUS: float = 14.0

@export var move_speed: float = 200.0
@export var team: int = 0

var is_selected: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = true
	nav_agent.radius = UNIT_RADIUS
	UnitManager.register_unit(self)

func _exit_tree() -> void:
	UnitManager.unregister_unit(self)

func _physics_process(_delta: float) -> void:
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
	draw_circle(Vector2.ZERO, UNIT_RADIUS, UNIT_COLOR)

func move_to(target_pos: Vector2) -> void:
	nav_agent.target_position = target_pos

func select() -> void:
	is_selected = true
	queue_redraw()
	selected.emit(self)

func deselect() -> void:
	is_selected = false
	queue_redraw()
	deselected.emit(self)
