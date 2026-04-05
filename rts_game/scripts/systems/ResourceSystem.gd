extends Node
## Manages resources (gold, wood). Placeholder for Phase 2.

signal resource_changed(type: String, amount: int)

var resources: Dictionary = {
	"gold": 500,
	"wood": 300,
}

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
