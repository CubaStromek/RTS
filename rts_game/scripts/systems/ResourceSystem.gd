extends Node
## Manages resources (gold, wood) and population cap.

signal resource_changed(type: String, amount: int)
signal population_changed(current: int, cap: int)

var resources: Dictionary = {
	"gold": 500,
	"wood": 300,
}

var population_cap: int = 15  # Starting cap (Town Hall gives 10, +5 base)
var _base_cap: int = 15

func get_resource(type: String) -> int:
	return resources.get(type, 0)

func add_resource(type: String, amount: int) -> void:
	resources[type] = resources.get(type, 0) + amount
	resource_changed.emit(type, resources[type])

func spend_resource(type: String, amount: int) -> bool:
	if resources.get(type, 0) >= amount:
		resources[type] -= amount
		resource_changed.emit(type, resources[type])
		return true
	return false

func get_population() -> int:
	var count: int = 0
	for unit in UnitManager.all_units:
		if unit.team == 0:
			count += 1
	return count

func can_train() -> bool:
	return get_population() < population_cap

func add_population_cap(amount: int) -> void:
	population_cap += amount
	population_changed.emit(get_population(), population_cap)

func remove_population_cap(amount: int) -> void:
	population_cap = max(_base_cap, population_cap - amount)
	population_changed.emit(get_population(), population_cap)
