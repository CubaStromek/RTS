extends "res://scenes/buildings/Building.gd"
## Barracks — trains soldiers.

const SOLDIER_COST_GOLD: int = 50
const SOLDIER_COST_WOOD: int = 0
const SOLDIER_TRAIN_TIME: float = 5.0

func _ready() -> void:
	super._ready()
	building_name = "Barracks"
	building_color = Color(0.6, 0.3, 0.15)
	max_hp = 600
	hp = max_hp

func train_soldier() -> bool:
	return queue_unit("soldier", SOLDIER_COST_GOLD, SOLDIER_COST_WOOD, SOLDIER_TRAIN_TIME)
