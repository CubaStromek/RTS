extends Node2D
## Brief flash line from attacker to target, fades quickly.

var from_pos: Vector2 = Vector2.ZERO
var to_pos: Vector2 = Vector2.ZERO
var _timer: float = 0.0
var _lifetime: float = 0.15
var _color: Color = Color(1.0, 0.8, 0.2)

func setup(from: Vector2, to: Vector2, color: Color = Color(1.0, 0.8, 0.2)) -> void:
	from_pos = from
	to_pos = to
	_color = color

func _process(delta: float) -> void:
	_timer += delta
	queue_redraw()
	if _timer >= _lifetime:
		queue_free()

func _draw() -> void:
	var alpha: float = 1.0 - (_timer / _lifetime)
	var width: float = 2.0 * alpha
	draw_line(from_pos - global_position, to_pos - global_position, Color(_color, alpha), width)
