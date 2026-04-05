extends CanvasLayer
## Game over overlay — shows victory or defeat message with restart button.

var _result_label: Label
var _detail_label: Label
var _restart_btn: Button
var _bg: ColorRect

func _ready() -> void:
	layer = 20

	_bg = ColorRect.new()
	_bg.color = Color(0, 0, 0, 0.7)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -200
	vbox.offset_right = 200
	vbox.offset_top = -100
	vbox.offset_bottom = 100
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

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(spacer)

	_restart_btn = Button.new()
	_restart_btn.text = "Restart Game"
	_restart_btn.custom_minimum_size = Vector2(200, 50)
	_restart_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_restart_btn.pressed.connect(_on_restart)
	vbox.add_child(_restart_btn)

func show_victory(waves_survived: int) -> void:
	_result_label.text = "VICTORY!"
	_result_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_detail_label.text = "You destroyed the enemy forces!\nWaves survived: %d" % waves_survived

func show_defeat(waves_survived: int) -> void:
	_result_label.text = "DEFEAT"
	_result_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.1))
	_detail_label.text = "Your Town Hall was destroyed.\nWaves survived: %d" % waves_survived

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
