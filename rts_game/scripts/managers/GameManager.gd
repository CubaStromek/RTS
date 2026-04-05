extends Node
## Global game state manager with win/lose conditions.

signal game_over(victory: bool)

enum GameState { PLAYING, GAME_OVER }
enum GameMode { WAVES, SANDBOX }

var current_state: GameState = GameState.PLAYING
var game_mode: GameMode = GameMode.WAVES
var game_started: bool = false
var waves_survived: int = 0

const GameOverScript := preload("res://scenes/ui/GameOverScreen.gd")

func _ready() -> void:
	print("GameManager initialized")

func _process(_delta: float) -> void:
	if not game_started:
		return
	if current_state != GameState.PLAYING:
		return
	_check_win_conditions()

func _check_win_conditions() -> void:
	# Sandbox mode: no win/lose conditions
	if game_mode == GameMode.SANDBOX:
		return

	# Lose: all town halls destroyed
	var town_halls := get_tree().get_nodes_in_group("townhalls")
	if town_halls.size() == 0:
		# Only check after the game has started (defer one frame)
		if Engine.get_process_frames() > 2:
			_trigger_game_over(false)
			return

	# Win: no enemy units left AND at least one wave has spawned
	if waves_survived > 0:
		var has_enemies := false
		for unit in UnitManager.all_units:
			if unit.team != 0:
				has_enemies = true
				break
		if not has_enemies:
			# Check if AI is still active
			var ai_node := get_tree().current_scene.get_node_or_null("AISystem")
			if ai_node and ai_node.wave_number >= 5:
				_trigger_game_over(true)

func _trigger_game_over(victory: bool) -> void:
	current_state = GameState.GAME_OVER
	game_over.emit(victory)

	var screen := CanvasLayer.new()
	screen.set_script(GameOverScript)
	get_tree().current_scene.add_child(screen)

	if victory:
		screen.show_victory(waves_survived)
	else:
		screen.show_defeat(waves_survived)

	get_tree().paused = true

func reset_state() -> void:
	current_state = GameState.PLAYING
	game_started = true
	waves_survived = 0

func register_wave_survived() -> void:
	waves_survived += 1
