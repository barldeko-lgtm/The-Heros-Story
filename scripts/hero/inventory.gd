class_name Inventory
extends RefCounted

const CAPACITY: int = 36

var items: Array = []

func add_item(item_instance):
	assert(item_instance != null, "Inventory cannot store a null item.")
	items.append(item_instance)
	if items.size() > CAPACITY:
		return items.pop_front()
	return null

func get_items() -> Array:
	return items.duplicate()
