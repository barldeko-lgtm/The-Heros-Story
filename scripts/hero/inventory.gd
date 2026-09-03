class_name Inventory
extends RefCounted

const CAPACITY: int = 36

var items: Array = []
var healing_potion_counts: Dictionary = {}

func add_item(item_instance):
	assert(item_instance != null, "Inventory cannot store a null item.")
	items.append(item_instance)
	if items.size() > CAPACITY:
		return items.pop_front()
	return null

func get_items() -> Array:
	return items.duplicate()

func remove_item(item_instance) -> bool:
	var item_index: int = items.find(item_instance)
	if item_index < 0:
		return false
	items.remove_at(item_index)
	return true

func add_healing_potion(potion_level: int, count: int = 1) -> void:
	if potion_level <= 0 or count <= 0:
		return
	healing_potion_counts[potion_level] = int(healing_potion_counts.get(potion_level, 0)) + count

func remove_healing_potion(potion_level: int) -> bool:
	var current_count: int = int(healing_potion_counts.get(potion_level, 0))
	if current_count <= 0:
		return false
	if current_count == 1:
		healing_potion_counts.erase(potion_level)
	else:
		healing_potion_counts[potion_level] = current_count - 1
	return true

func get_healing_potion_count(potion_level: int) -> int:
	return int(healing_potion_counts.get(potion_level, 0))

func get_healing_potion_counts() -> Dictionary:
	return healing_potion_counts.duplicate()

func get_total_healing_potion_count() -> int:
	var total: int = 0
	for count in healing_potion_counts.values():
		total += int(count)
	return total
