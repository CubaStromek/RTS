extends Node2D
## Death explosion effect — expanding fading ring with particles.

var _timer: float = 0.0
var _lifetime: float = 0.6
var _color: Color = Color(1.0, 0.4, 0.1)
var _particles: Array[Dictionary] = []

func setup(pos: Vector2, color: Color) -> void:
	global_position = pos
	_color = color
	# Create scattered particles
	for i in range(8):
		var angle: float = randf() * TAU
		var speed: float = randf_range(40, 120)
		_particles.append({
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"size": randf_range(2, 5),
		})

func _process(delta: float) -> void:
	_timer += delta
	for p in _particles:
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.95
	queue_redraw()
	if _timer >= _lifetime:
		queue_free()

func _draw() -> void:
	var progress: float = _timer / _lifetime
	var alpha: float = 1.0 - progress

	# Expanding ring
	var ring_radius: float = 10.0 + progress * 30.0
	draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 24, Color(_color, alpha * 0.6), 2.0)

	# Particles
	for p in _particles:
		var col := Color(_color, alpha)
		var size: float = p["size"] * (1.0 - progress)
		draw_circle(p["pos"], size, col)
