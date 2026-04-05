extends Control
## Main menu — title screen with game mode selection.

func _ready() -> void:
	# Dark background
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.04, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.offset_left = -300
	center.offset_right = 300
	center.offset_top = -250
	center.offset_bottom = 250
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 12)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	# Title
	var title := Label.new()
	title.text = "Medieval RTS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "Build. Command. Conquer."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(spacer)

	# Waves Mode button
	var waves_btn := _create_mode_button(
		"Waves Mode",
		"Defend against 5 waves of increasingly powerful enemies.",
	)
	waves_btn.pressed.connect(_on_waves_pressed)
	center.add_child(waves_btn)

	# Waves description
	var waves_desc := Label.new()
	waves_desc.text = "Classic gameplay — build your base and survive the onslaught."
	waves_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	waves_desc.add_theme_font_size_override("font_size", 14)
	waves_desc.add_theme_color_override("font_color", Color(0.6, 0.55, 0.45))
	waves_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(waves_desc)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	spacer2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(spacer2)

	# Sandbox Mode button
	var sandbox_btn := _create_mode_button(
		"Sandbox Mode",
		"Free build with no enemies — experiment and expand at your own pace.",
	)
	sandbox_btn.pressed.connect(_on_sandbox_pressed)
	center.add_child(sandbox_btn)

	# Sandbox description
	var sandbox_desc := Label.new()
	sandbox_desc.text = "No enemies, extra resources — build freely and explore."
	sandbox_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sandbox_desc.add_theme_font_size_override("font_size", 14)
	sandbox_desc.add_theme_color_override("font_color", Color(0.6, 0.55, 0.45))
	sandbox_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(sandbox_desc)

func _create_mode_button(text: String, _tooltip_text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 60)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.15, 0.1, 0.9)
	style.border_color = Color(0.65, 0.5, 0.2)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = Color(0.3, 0.22, 0.12, 0.95)
	hover_style.border_color = Color(0.85, 0.65, 0.25)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = Color(0.15, 0.1, 0.06, 0.95)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.6))
	btn.add_theme_font_size_override("font_size", 24)

	return btn

func _on_waves_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.WAVES
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _on_sandbox_pressed() -> void:
	GameManager.game_mode = GameManager.GameMode.SANDBOX
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
