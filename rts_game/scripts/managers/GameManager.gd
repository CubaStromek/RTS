extends Node
## Global game state manager.

enum GameState { PLAYING, PAUSED, MENU }

var current_state: GameState = GameState.PLAYING

func _ready() -> void:
	print("GameManager initialized")
