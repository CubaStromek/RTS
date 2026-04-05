extends BuildingBase
## Barracks — trains soldiers, archers, and knights.

const SOLDIER_COST_GOLD: int = 50
const SOLDIER_COST_WOOD: int = 0
const SOLDIER_TRAIN_TIME: float = 5.0

const ARCHER_COST_GOLD: int = 70
const ARCHER_COST_WOOD: int = 30
const ARCHER_TRAIN_TIME: float = 7.0

const KNIGHT_COST_GOLD: int = 120
const KNIGHT_COST_WOOD: int = 50
const KNIGHT_TRAIN_TIME: float = 12.0

func _ready() -> void:
	super._ready()
	building_name = "Barracks"
	building_color = Color(0.6, 0.3, 0.15)
	max_hp = 600
	hp = max_hp

func _process(delta: float) -> void:
	super._process(delta)

func train_soldier() -> bool:
	return queue_unit("soldier", SOLDIER_COST_GOLD, SOLDIER_COST_WOOD, SOLDIER_TRAIN_TIME)

func train_archer() -> bool:
	return queue_unit("archer", ARCHER_COST_GOLD, ARCHER_COST_WOOD, ARCHER_TRAIN_TIME)

func train_knight() -> bool:
	print("Train knight requested. Gold: %d, Wood: %d, Pop: %d/%d" % [
		ResourceSystem.get_resource("gold"),
		ResourceSystem.get_resource("wood"),
		ResourceSystem.get_population(),
		ResourceSystem.population_cap,
	])
	var result := queue_unit("knight", KNIGHT_COST_GOLD, KNIGHT_COST_WOOD, KNIGHT_TRAIN_TIME)
	print("Train knight result: %s" % str(result))
	return result
