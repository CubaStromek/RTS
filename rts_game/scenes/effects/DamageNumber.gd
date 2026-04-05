extends Node2D
## Floating damage number that rises and fades out.

var amount: int = 0
var _lifetime: float = 0.8
var _timer: float = 0.0
var _color: Color = Color.WHITE

func setup(dmg: int, pos: Vector2, is_heal: bool = false) -> void:
	amount = dmg
	global_position = pos + Vector2(randf_range(-10, 10), -20)
	_color = Color(0.3, 1.0, 0.3) if is_heal else Color(1.0, 0.9, 0.2)

func _process(delta: float) -> void:
	_timer += delta
	var progress: float = _timer / _lifetime
	position.y -= 40.0 * delta
	modulate.a = 1.0 - progress
	if _timer >= _lifetime:
		queue_free()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var text := str(amount)
	draw_string(font, Vector2(-12, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, _color)
