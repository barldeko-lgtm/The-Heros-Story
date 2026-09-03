class_name BeltPotionRules
extends RefCounted

const DefaultPotionDefinitions := [
	preload("res://data/items/consumables/healing_potion_ilvl10.tres"),
	preload("res://data/items/consumables/healing_potion_ilvl20.tres"),
]

func get_capacity(belt_item) -> int:
	if belt_item == null or belt_item.definition == null or belt_item.definition.equipment_slot != "belt":
		return 0
	match int(belt_item.rarity):
		1: return 2
		2: return 3
		3: return 4
	return 1

func get_max_potion_level(belt_item) -> int:
	if get_capacity(belt_item) <= 0:
		return 0
	return maxi(0, int(belt_item.item_level))

func get_best_supported_potion(belt_item, potion_definitions: Array = DefaultPotionDefinitions):
	var max_level: int = get_max_potion_level(belt_item)
	var best_definition = null
	for potion_definition in potion_definitions:
		if potion_definition == null or potion_definition.potion_level > max_level:
			continue
		if best_definition == null or potion_definition.healing_amount > best_definition.healing_amount:
			best_definition = potion_definition
	return best_definition

func get_potential_healing(belt_item, potion_definitions: Array = DefaultPotionDefinitions) -> float:
	var capacity: int = get_capacity(belt_item)
	if capacity <= 0:
		return 0.0
	var best_potion = get_best_supported_potion(belt_item, potion_definitions)
	if best_potion == null:
		return 0.0
	return float(capacity) * float(best_potion.healing_amount)
