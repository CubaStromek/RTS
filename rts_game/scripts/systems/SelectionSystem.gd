extends Node
## Handles unit selection: click, drag box, shift-click, control groups.

signal selection_changed(units: Array[CharacterBody2D])

var selected_units: Array[CharacterBody2D] = []
var control_groups: Dictionary = {}  # int -> Array[CharacterBody2D]

var _is_dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _selection_box: Panel = null

func _ready() -> void:
	# SelectionBox will be found after scene tree is ready
	call_deferred("_find_selection_box")

func _find_selection_box() -> void:
	var main := get_tree().current_scene
	if main:
		_selection_box = main.get_node_or_null("UI/SelectionBox")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _is_dragging:
		_update_selection_box(event.position)
	elif event is InputEventKey and event.pressed:
		_handle_key(event)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_start = event.position
			_is_dragging = true
		else:
			# Release — finalize selection
			if _is_dragging:
				_is_dragging = false
				_hide_selection_box()
				var drag_end := event.position
				var drag_dist := _drag_start.distance_to(drag_end)

				if drag_dist < 5.0:
					# Click select
					_click_select(event)
				else:
					# Box select
					_box_select(_drag_start, drag_end, event.shift_pressed)

	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if selected_units.size() > 0:
			var camera := get_viewport().get_camera_2d()
			var world_pos: Vector2
			if camera:
				world_pos = camera.get_global_mouse_position()
			else:
				world_pos = get_viewport().get_mouse_position()
			CommandSystem.issue_move(selected_units, world_pos)

func _handle_key(event: InputEventKey) -> void:
	var num := event.keycode - KEY_0
	if num >= 0 and num <= 9:
		if event.ctrl_pressed:
			# Ctrl+number = save group
			control_groups[num] = selected_units.duplicate()
		else:
			# Number = recall group
			if num in control_groups:
				_set_selection(control_groups[num], false)

func _click_select(event: InputEventMouseButton) -> void:
	var camera := get_viewport().get_camera_2d()
	var world_pos: Vector2
	if camera:
		world_pos = camera.get_global_mouse_position()
	else:
		world_pos = get_viewport().get_mouse_position()

	var closest_unit: CharacterBody2D = null
	var closest_dist: float = 20.0  # Max click distance

	for unit in UnitManager.all_units:
		var dist := world_pos.distance_to(unit.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_unit = unit

	if closest_unit:
		if event.shift_pressed:
			_toggle_unit(closest_unit)
		else:
			_set_selection([closest_unit], false)
	elif not event.shift_pressed:
		_clear_selection()

func _box_select(start: Vector2, end: Vector2, additive: bool) -> void:
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return

	# Convert screen coords to world coords
	var cam_pos := camera.global_position
	var cam_zoom := camera.zoom
	var viewport_size := get_viewport().get_visible_rect().size

	var world_start := cam_pos + (start - viewport_size / 2.0) / cam_zoom
	var world_end := cam_pos + (end - viewport_size / 2.0) / cam_zoom

	var rect := Rect2(
		Vector2(min(world_start.x, world_end.x), min(world_start.y, world_end.y)),
		Vector2(abs(world_end.x - world_start.x), abs(world_end.y - world_start.y))
	)

	var units_in_box := UnitManager.get_units_in_rect(rect)
	_set_selection(units_in_box, additive)

func _set_selection(units: Array, additive: bool) -> void:
	if not additive:
		_clear_selection()
	for unit in units:
		if unit not in selected_units:
			selected_units.append(unit)
			unit.select()
	selection_changed.emit(selected_units)

func _toggle_unit(unit: CharacterBody2D) -> void:
	if unit in selected_units:
		selected_units.erase(unit)
		unit.deselect()
	else:
		selected_units.append(unit)
		unit.select()
	selection_changed.emit(selected_units)

func _clear_selection() -> void:
	for unit in selected_units:
		unit.deselect()
	selected_units.clear()
	selection_changed.emit(selected_units)

func _update_selection_box(current_pos: Vector2) -> void:
	if _selection_box:
		var rect := Rect2(
			Vector2(min(_drag_start.x, current_pos.x), min(_drag_start.y, current_pos.y)),
			Vector2(abs(current_pos.x - _drag_start.x), abs(current_pos.y - _drag_start.y))
		)
		_selection_box.visible = true
		_selection_box.position = rect.position
		_selection_box.size = rect.size

func _hide_selection_box() -> void:
	if _selection_box:
		_selection_box.visible = false
