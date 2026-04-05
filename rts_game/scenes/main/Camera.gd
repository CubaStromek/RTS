extends Camera2D
## RTS camera with WASD/arrow movement, edge scrolling, and mouse wheel zoom.

const MOVE_SPEED: float = 800.0
const EDGE_SCROLL_MARGIN: int = 20
const EDGE_SCROLL_SPEED: float = 600.0
const ZOOM_STEP: float = 0.1
const ZOOM_MIN: float = 0.3
const ZOOM_MAX: float = 2.0

func _process(delta: float) -> void:
	var direction := Vector2.ZERO

	# WASD / arrow keys
	direction.x = Input.get_axis("camera_left", "camera_right")
	direction.y = Input.get_axis("camera_up", "camera_down")

	# Edge scrolling
	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size := get_viewport_rect().size
	if mouse_pos.x <= EDGE_SCROLL_MARGIN:
		direction.x -= 1.0
	elif mouse_pos.x >= viewport_size.x - EDGE_SCROLL_MARGIN:
		direction.x += 1.0
	if mouse_pos.y <= EDGE_SCROLL_MARGIN:
		direction.y -= 1.0
	elif mouse_pos.y >= viewport_size.y - EDGE_SCROLL_MARGIN:
		direction.y += 1.0

	# Apply movement (faster when zoomed out)
	var speed_multiplier := 1.0 / zoom.x
	position += direction.normalized() * MOVE_SPEED * speed_multiplier * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_camera(ZOOM_STEP)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_camera(-ZOOM_STEP)

func _zoom_camera(step: float) -> void:
	var new_zoom := clampf(zoom.x + step, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(new_zoom, new_zoom)
