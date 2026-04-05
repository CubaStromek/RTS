extends CanvasLayer
## Main game HUD — medieval themed, resources, hotkeys, kill counter, wave timer, production queue.

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var wood_label: Label = $TopBar/WoodLabel
@onready var pop_label: Label = $TopBar/PopLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var kill_label: Label = $TopBar/KillLabel
@onready var info_panel: PanelContainer = $BottomPanel
@onready var info_name: Label = $BottomPanel/VBox/EntityName
@onready var info_hp: Label = $BottomPanel/VBox/EntityHP
@onready var info_stats: Label = $BottomPanel/VBox/EntityStats
@onready var production_container: HBoxContainer = $BottomPanel/VBox/ProductionButtons
@onready var queue_label: Label = $BottomPanel/VBox/QueueLabel
@onready var production_queue_display: HBoxContainer = $BottomPanel/VBox/ProductionQueue
@onready var build_panel: HBoxContainer = $BuildBar

var _selected_building: StaticBody2D = null
var _elapsed_time: float = 0.0
var _kill_count: int = 0
var _tooltip: Control = null

func _ready() -> void:
	ResourceSystem.resource_changed.connect(_on_resource_changed)
	SelectionSystem.selection_changed.connect(_on_selection_changed)
	_update_resources()
	info_panel.visible = false
	_setup_build_buttons()
	_apply_medieval_theme()
	# Track kills
	UnitManager.unit_died.connect(_on_unit_died)
	# Hide wave UI in sandbox mode
	if GameManager.game_mode == GameManager.GameMode.SANDBOX:
		wave_label.visible = false
		timer_label.text = "Sandbox"

func _process(delta: float) -> void:
	_elapsed_time += delta
	pop_label.text = "Pop: %d/%d" % [ResourceSystem.get_population(), ResourceSystem.population_cap]

	if GameManager.game_mode == GameManager.GameMode.SANDBOX:
		timer_label.text = "Sandbox | %s" % _format_time(_elapsed_time)
	else:
		wave_label.text = "Wave: %d" % GameManager.waves_survived
		# Wave countdown
		var ai_node := get_tree().current_scene.get_node_or_null("AISystem")
		if ai_node and ai_node.wave_number < 5:
			var countdown: float = ai_node._wave_timer
			timer_label.text = "Next wave: %ds" % int(countdown)
		else:
			timer_label.text = "Time: %s" % _format_time(_elapsed_time)

	kill_label.text = "Kills: %d" % _kill_count

	if _selected_building and is_instance_valid(_selected_building):
		_update_building_info(_selected_building)
		_update_production_queue_display(_selected_building)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return

	# Building hotkeys: B opens build menu concept
	# Direct build hotkeys
	var build_sys := get_node_or_null("/root/BuildSystem")
	if not build_sys:
		return

	if event.keycode == KEY_B:
		# B+B = Barracks, B+F = Farm, B+T = Tower handled by next keypress
		pass

	# Production hotkeys when building is selected
	if _selected_building and is_instance_valid(_selected_building):
		match event.keycode:
			KEY_Q:
				_try_first_production()
			KEY_W:
				_try_second_production()
			KEY_E:
				_try_third_production()

func _try_first_production() -> void:
	if _selected_building.has_method("train_worker"):
		_selected_building.train_worker()
	elif _selected_building.has_method("train_soldier"):
		_selected_building.train_soldier()

func _try_second_production() -> void:
	if _selected_building.has_method("train_archer"):
		_selected_building.train_archer()

func _try_third_production() -> void:
	if _selected_building.has_method("train_knight"):
		_selected_building.train_knight()

func _apply_medieval_theme() -> void:
	# Dark medieval style for panels
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.1, 0.08, 0.9)
	panel_style.border_color = Color(0.65, 0.5, 0.2)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.content_margin_left = 10.0
	panel_style.content_margin_right = 10.0
	panel_style.content_margin_top = 6.0
	panel_style.content_margin_bottom = 6.0
	info_panel.add_theme_stylebox_override("panel", panel_style)

	# Top bar background
	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color(0.12, 0.08, 0.06, 0.85)
	top_style.border_color = Color(0.55, 0.4, 0.15)
	top_style.border_width_bottom = 2
	top_style.content_margin_left = 12.0
	top_style.content_margin_top = 6.0
	top_style.content_margin_bottom = 6.0
	var top_bar := $TopBar
	# Wrap top bar with panel
	var top_panel := PanelContainer.new()
	top_panel.anchors_preset = Control.PRESET_TOP_WIDE
	top_panel.offset_bottom = 40.0
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_panel.add_theme_stylebox_override("panel", top_style)

	# Set label colors
	var gold_color := Color(1.0, 0.85, 0.3)
	var text_color := Color(0.9, 0.85, 0.75)
	gold_label.add_theme_color_override("font_color", gold_color)
	wood_label.add_theme_color_override("font_color", Color(0.6, 0.85, 0.4))
	pop_label.add_theme_color_override("font_color", text_color)
	wave_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
	timer_label.add_theme_color_override("font_color", text_color)
	kill_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

	# Info panel label colors
	info_name.add_theme_color_override("font_color", gold_color)
	info_hp.add_theme_color_override("font_color", text_color)
	info_stats.add_theme_color_override("font_color", text_color)
	queue_label.add_theme_color_override("font_color", text_color)

func _on_unit_died(unit: CharacterBody2D) -> void:
	if unit.team != 0:
		_kill_count += 1

func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]

func _update_resources() -> void:
	gold_label.text = "Gold: %d" % ResourceSystem.get_resource("gold")
	wood_label.text = "Wood: %d" % ResourceSystem.get_resource("wood")

func _on_resource_changed(_type: String, _amount: int) -> void:
	_update_resources()

func _on_selection_changed(units: Array[CharacterBody2D]) -> void:
	_selected_building = null
	_clear_production_buttons()
	_clear_production_queue()

	if units.size() == 0:
		info_panel.visible = false
		return

	info_panel.visible = true
	if units.size() == 1:
		var unit := units[0]
		info_name.text = unit.unit_type.capitalize()
		info_hp.text = "HP: %d / %d" % [unit.hp, unit.max_hp]
		info_stats.text = "ATK: %d | SPD: %d | RNG: %d" % [unit.attack_damage, int(unit.move_speed), int(unit.attack_range)]
	else:
		info_name.text = "%d units selected" % units.size()
		var total_hp: int = 0
		var total_max: int = 0
		for u in units:
			total_hp += u.hp
			total_max += u.max_hp
		info_hp.text = "Total HP: %d / %d" % [total_hp, total_max]
		info_stats.text = ""
	queue_label.text = ""

func show_building_info(building: StaticBody2D) -> void:
	_selected_building = building
	info_panel.visible = true
	_update_building_info(building)
	_setup_production_buttons(building)

func _update_building_info(building: StaticBody2D) -> void:
	info_name.text = building.building_name
	info_hp.text = "HP: %d / %d" % [building.hp, building.max_hp]
	if building.production_queue.size() > 0:
		var progress: float = building.get_production_progress()
		var train_text := "Training: %s (%.0f%%) | Queue: %d" % [
			building.production_queue[0]["type"],
			progress * 100.0,
			building.production_queue.size()
		]
		queue_label.text = train_text
		info_stats.text = train_text
	else:
		queue_label.text = ""
		info_stats.text = ""

func _update_production_queue_display(building: StaticBody2D) -> void:
	_clear_production_queue()
	for i in range(building.production_queue.size()):
		var item: Dictionary = building.production_queue[i]
		var queue_item := ColorRect.new()
		queue_item.custom_minimum_size = Vector2(20, 20)
		# Color based on unit type
		match item["type"]:
			"soldier":
				queue_item.color = Color(0.2, 0.4, 0.9)
			"archer":
				queue_item.color = Color(0.6, 0.3, 0.7)
			"knight":
				queue_item.color = Color(0.8, 0.75, 0.2)
			"worker":
				queue_item.color = Color(0.2, 0.7, 0.3)
			_:
				queue_item.color = Color(0.5, 0.5, 0.5)
		production_queue_display.add_child(queue_item)

		# Progress bar on first item
		if i == 0:
			var progress_bar := ColorRect.new()
			var prog: float = building.get_production_progress()
			progress_bar.custom_minimum_size = Vector2(maxf(1.0, 20.0 * prog), 3)
			progress_bar.color = Color(0.0, 1.0, 0.0, 0.8)
			progress_bar.position = Vector2(0, 17)
			queue_item.add_child(progress_bar)

func _setup_production_buttons(building: StaticBody2D) -> void:
	_clear_production_buttons()
	if building.has_method("train_soldier"):
		_add_button("[Q] Soldier (50g)", func() -> void: building.train_soldier())
	if building.has_method("train_archer"):
		_add_button("[W] Archer (70g 30w)", func() -> void: building.train_archer())
	if building.has_method("train_knight"):
		_add_button("[E] Knight (120g 50w)", func() -> void: building.train_knight())
	if building.has_method("train_worker"):
		_add_button("[Q] Worker (50g 25w)", func() -> void: building.train_worker())
	# Blacksmith research buttons
	if building.has_method("research_iron_weapons"):
		_add_button("Iron Weapons (150g 50w)", func() -> void: building.research_iron_weapons())
	if building.has_method("research_iron_armor"):
		_add_button("Iron Armor (100g 100w)", func() -> void: building.research_iron_armor())
	if building.has_method("research_swift_boots"):
		_add_button("Swift Boots (80g 60w)", func() -> void: building.research_swift_boots())
	# Market trade buttons
	if building.has_method("trade_gold_for_wood"):
		_add_button("Gold->Wood (100)", func() -> void: building.trade_gold_for_wood())
	if building.has_method("trade_wood_for_gold"):
		_add_button("Wood->Gold (100)", func() -> void: building.trade_wood_for_gold())

func _setup_build_buttons() -> void:
	var build_sys := get_node_or_null("/root/BuildSystem")
	if not build_sys:
		return
	_add_build_button("Barracks (150g 100w)", "barracks", build_sys)
	_add_build_button("Farm (50g 75w)", "farm", build_sys)
	_add_build_button("Tower (100g 80w)", "tower", build_sys)
	_add_build_button("Blacksmith (200g 150w)", "blacksmith", build_sys)
	_add_build_button("Market (120g 80w)", "market", build_sys)

func _add_build_button(text: String, building_type: String, build_sys: Node) -> void:
	var btn := Button.new()
	btn.text = text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(btn)
	btn.pressed.connect(func() -> void:
		build_sys.enter_build_mode(building_type)
	)
	build_panel.add_child(btn)

func _add_button(text: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_style_button(btn)
	btn.pressed.connect(callback)
	production_container.add_child(btn)

func _style_button(btn: Button) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.15, 0.1, 0.9)
	normal_style.border_color = Color(0.55, 0.4, 0.15)
	normal_style.border_width_left = 1
	normal_style.border_width_right = 1
	normal_style.border_width_top = 1
	normal_style.border_width_bottom = 1
	normal_style.corner_radius_top_left = 3
	normal_style.corner_radius_top_right = 3
	normal_style.corner_radius_bottom_left = 3
	normal_style.corner_radius_bottom_right = 3
	normal_style.content_margin_left = 8.0
	normal_style.content_margin_right = 8.0
	normal_style.content_margin_top = 4.0
	normal_style.content_margin_bottom = 4.0
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.22, 0.12, 0.95)
	hover_style.border_color = Color(0.75, 0.55, 0.2)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := normal_style.duplicate()
	pressed_style.bg_color = Color(0.15, 0.1, 0.06, 0.95)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.6))

func _clear_production_buttons() -> void:
	for child in production_container.get_children():
		child.queue_free()

func _clear_production_queue() -> void:
	for child in production_queue_display.get_children():
		child.queue_free()
