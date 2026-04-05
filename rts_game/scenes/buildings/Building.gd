extends StaticBody2D
## Base building with HP, selection, and production queue.

signal selected(building: StaticBody2D)
signal deselected(building: StaticBody2D)
signal unit_trained(building: StaticBody2D, unit_type: String)

const BUILDING_SIZE := Vector2(64, 64)
const HP_BAR_WIDTH: float = 60.0
const HP_BAR_HEIGHT: float = 5.0
const HP_BAR_OFFSET_Y: float = -42.0

@export var max_hp: int = 500
@export var team: int = 0
@export var building_name: String = "Building"
@export var building_color: Color = Color(0.5, 0.35, 0.2)

var hp: int
var is_selected: bool = false
var production_queue: Array[Dictionary] = []
var _production_timer: float = 0.0
var rally_point: Vector2 = Vector2.ZERO

func _ready() -> void:
	hp = max_hp
	rally_point = global_position + Vector2(0, 80)
	collision_layer = 2

func _process(delta: float) -> void:
	if production_queue.size() > 0:
		_production_timer -= delta
		if _production_timer <= 0.0:
			_finish_production()

func _draw() -> void:
	# Building body
	var rect := Rect2(-BUILDING_SIZE / 2.0, BUILDING_SIZE)
	draw_rect(rect, building_color)
	if is_selected:
		draw_rect(rect, Color(0.0, 1.0, 0.0, 0.4), false, 2.0)
		# Rally point indicator
		draw_line(Vector2.ZERO, rally_point - global_position, Color(0.0, 1.0, 0.0, 0.3), 1.0)

	# HP bar (only if damaged)
	if hp < max_hp:
		var bar_x := -HP_BAR_WIDTH / 2.0
		var bar_y := HP_BAR_OFFSET_Y
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH, HP_BAR_HEIGHT), Color(0.2, 0.2, 0.2))
		var hp_ratio := float(hp) / float(max_hp)
		var fill_color := Color(0.0, 0.8, 0.0) if hp_ratio > 0.5 else Color(0.9, 0.2, 0.0)
		draw_rect(Rect2(bar_x, bar_y, HP_BAR_WIDTH * hp_ratio, HP_BAR_HEIGHT), fill_color)

func queue_unit(unit_type: String, cost_gold: int, cost_wood: int, train_time: float) -> bool:
	if not ResourceSystem.spend_resource("gold", cost_gold):
		return false
	if not ResourceSystem.spend_resource("wood", cost_wood):
		# Refund gold
		ResourceSystem.add_resource("gold", cost_gold)
		return false

	production_queue.append({
		"type": unit_type,
		"time": train_time,
	})
	if production_queue.size() == 1:
		_production_timer = train_time
	return true

func _finish_production() -> void:
	var item: Dictionary = production_queue.pop_front()
	unit_trained.emit(self, item["type"])
	if production_queue.size() > 0:
		_production_timer = production_queue[0]["time"]

func take_damage(amount: int, _attacker: CharacterBody2D) -> void:
	hp -= amount
	queue_redraw()
	if hp <= 0:
		queue_free()

func select() -> void:
	is_selected = true
	queue_redraw()
	selected.emit(self)

func deselect() -> void:
	is_selected = false
	queue_redraw()
	deselected.emit(self)

func get_production_progress() -> float:
	if production_queue.size() == 0:
		return 0.0
	var total_time: float = production_queue[0]["time"]
	if total_time <= 0.0:
		return 1.0
	return 1.0 - (_production_timer / total_time)
