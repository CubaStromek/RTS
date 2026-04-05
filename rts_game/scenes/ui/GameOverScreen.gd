extends CanvasLayer
## Game over overlay — shows victory or defeat message with stats and restart button.

var _result_label: Label
var _detail_label: Label
var _stats_label: Label
var _restart_btn: Button
var _menu_btn: Button
var _bg: ColorRect
var _start_time: float = 0.0

func _ready() -> void:
	layer = 20
	_start_time = Time.get_ticks_msec() / 1000.0

	_bg = ColorRect.new()
	_bg.color = Color(0, 0, 0, 0.8)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -250
	vbox.offset_right = 250
	vbox.offset_top = -150
	vbox.offset_bottom = 150
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)

	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 48)
	_result_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_result_label)

	_detail_label = Label.new()
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_label.add_theme_font_size_override("font_size", 20)
	_detail_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_detail_label)

	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.add_theme_font_size_override("font_size", 16)
	_stats_label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6))
	_stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_stats_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(spacer)

	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.15, 0.1, 0.9)
	btn_style.border_color = Color(0.65, 0.5, 0.2)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4

	_restart_btn = Button.new()
	_restart_btn.text = "Restart Game"
	_restart_btn.custom_minimum_size = Vector2(200, 50)
	_restart_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_restart_btn.pressed.connect(_on_restart)
	_restart_btn.add_theme_stylebox_override("normal", btn_style)
	_restart_btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	vbox.add_child(_restart_btn)

	_menu_btn = Button.new()
	_menu_btn.text = "Main Menu"
	_menu_btn.custom_minimum_size = Vector2(200, 50)
	_menu_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_btn.pressed.connect(_on_main_menu)
	_menu_btn.add_theme_stylebox_override("normal", btn_style.duplicate())
	_menu_btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	vbox.add_child(_menu_btn)

func show_victory(waves_survived: int) -> void:
	_result_label.text = "VICTORY!"
	_result_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_detail_label.text = "You destroyed the enemy forces!\nWaves survived: %d" % waves_survived
	_show_stats()
	var snd := get_node_or_null("/root/SoundSystem")
	if snd:
		snd.play("victory")

func show_defeat(waves_survived: int) -> void:
	_result_label.text = "DEFEAT"
	_result_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.1))
	_detail_label.text = "Your Town Hall was destroyed.\nWaves survived: %d" % waves_survived
	_show_stats()
	var snd := get_node_or_null("/root/SoundSystem")
	if snd:
		snd.play("defeat")

func _show_stats() -> void:
	var gold := ResourceSystem.get_resource("gold")
	var wood := ResourceSystem.get_resource("wood")
	var friendly_count: int = 0
	for unit in UnitManager.all_units:
		if unit.team == 0:
			friendly_count += 1
	_stats_label.text = "Resources: %dg %dw | Units alive: %d" % [gold, wood, friendly_count]

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
