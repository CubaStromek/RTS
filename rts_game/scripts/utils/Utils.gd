extends Node
## General utility functions.

static func screen_to_world(screen_pos: Vector2, camera: Camera2D) -> Vector2:
	var viewport_size := camera.get_viewport_rect().size
	return camera.global_position + (screen_pos - viewport_size / 2.0) / camera.zoom
