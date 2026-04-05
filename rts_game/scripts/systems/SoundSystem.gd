extends Node
## Sound system — generates and plays procedural sound effects.
## Uses AudioStreamGenerator for placeholder sounds until real assets are added.

var _players: Dictionary = {}

func _ready() -> void:
	_create_sound("attack", 0.1, 400.0, 200.0)
	_create_sound("death", 0.3, 200.0, 50.0)
	_create_sound("select", 0.05, 800.0, 800.0)
	_create_sound("move", 0.05, 600.0, 500.0)
	_create_sound("build", 0.15, 300.0, 400.0)

func play(sound_name: String) -> void:
	if sound_name in _players:
		var player: AudioStreamPlayer = _players[sound_name]
		if not player.playing:
			player.play()

func _create_sound(sound_name: String, duration: float, freq_start: float, freq_end: float) -> void:
	var sample_rate: float = 22050.0
	var samples: int = int(sample_rate * duration)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = int(sample_rate)
	stream.stereo = false

	var data := PackedByteArray()
	data.resize(samples)
	for i in range(samples):
		var t: float = float(i) / sample_rate
		var progress: float = float(i) / float(samples)
		var freq: float = lerp(freq_start, freq_end, progress)
		var amplitude: float = (1.0 - progress) * 0.5  # Fade out
		var sample: float = sin(t * freq * TAU) * amplitude
		data[i] = int((sample + 1.0) * 0.5 * 255.0)
	stream.data = data

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -10.0
	add_child(player)
	_players[sound_name] = player
