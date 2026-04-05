extends CanvasLayer
## Main game HUD — resources, population, wave counter, info panel, build buttons.

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var wood_label: Label = $TopBar/WoodLabel
@onready var pop_label: Label = $TopBar/PopLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var info_panel: PanelContainer = $BottomPanel
@onready var info_name: Label = $BottomPanel/VBox/EntityName
@onready var info_hp: Label = $BottomPanel/VBox/EntityHP
@onready var info_stats: Label = $BottomPanel/VBox/EntityStats
@onready var production_container: HBoxContainer = $BottomPanel/VBox/ProductionButtons
@onready var queue_label: Label = $BottomPanel/VBox/QueueLabel
@onready var build_panel: HBoxContainer = $BuildBar

var _selected_building: StaticBody2D = null

func _ready() -> void:
	ResourceSystem.resource_changed.connect(_on_resource_changed)
	SelectionSystem.selection_changed.connect(_on_selection_changed)
	_update_resources()
	info_panel.visible = false
	_setup_build_buttons()

func _process(_delta: float) -> void:
	pop_label.text = "Pop: %d/%d" % [ResourceSystem.get_population(), ResourceSystem.population_cap]
	wave_label.text = "Wave: %d" % GameManager.waves_survived
	if _selected_building and is_instance_valid(_selected_building):
		_update_building_info(_selected_building)

func _update_resources() -> void:
	gold_label.text = "Gold: %d" % ResourceSystem.get_resource("gold")
	wood_label.text = "Wood: %d" % ResourceSystem.get_resource("wood")

func _on_resource_changed(_type: String, _amount: int) -> void:
	_update_resources()

func _on_selection_changed(units: Array[CharacterBody2D]) -> void:
	_selected_building = null
	_clear_production_buttons()

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
	print("show_building_info: %s, queue: %d, timer: %.1f" % [building.building_name, building.production_queue.size(), building._production_timer])
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

func _setup_production_buttons(building: StaticBody2D) -> void:
	_clear_production_buttons()
	if building.has_method("train_soldier"):
		_add_button("Soldier (50g)", func() -> void: building.train_soldier())
	if building.has_method("train_archer"):
		_add_button("Archer (70g 30w)", func() -> void: building.train_archer())
	if building.has_method("train_knight"):
		_add_button("Knight (120g 50w)", func() -> void: building.train_knight())
	if building.has_method("train_worker"):
		_add_button("Worker (50g 25w)", func() -> void: building.train_worker())

func _setup_build_buttons() -> void:
	var build_sys := get_node_or_null("/root/BuildSystem")
	if not build_sys:
		return
	_add_build_button("Barracks (150g 100w)", "barracks", build_sys)
	_add_build_button("Farm (50g 75w)", "farm", build_sys)
	_add_build_button("Tower (100g 80w)", "tower", build_sys)

func _add_build_button(text: String, building_type: String, build_sys: Node) -> void:
	var btn := Button.new()
	btn.text = text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.pressed.connect(func() -> void:
		build_sys.enter_build_mode(building_type)
	)
	build_panel.add_child(btn)

func _add_button(text: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.pressed.connect(callback)
	production_container.add_child(btn)

func _clear_production_buttons() -> void:
	for child in production_container.get_children():
		child.queue_free()
