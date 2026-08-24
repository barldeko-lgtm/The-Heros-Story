class_name Equipment
extends RefCounted

var equipped_items: Dictionary = {}

func equip_if_empty(item_instance) -> bool:
	if item_instance == null or item_instance.definition == null:
		return false
	var slot: String = item_instance.definition.equipment_slot
	if slot.is_empty() or equipped_items.has(slot):
		return false
	equipped_items[slot] = item_instance
	return true

func replace_item(item_instance):
	if item_instance == null or item_instance.definition == null:
		return null
	var slot: String = item_instance.definition.equipment_slot
	if slot.is_empty():
		return null
	var previous_item = equipped_items.get(slot)
	equipped_items[slot] = item_instance
	return previous_item

func get_item(slot: String):
	return equipped_items.get(slot)

func get_all_items() -> Array:
	return equipped_items.values()

func get_strength_bonus() -> int:
	var total: int = 0
	for item_instance in equipped_items.values():
		total += item_instance.definition.strength_bonus
	return total

func get_max_hp_bonus() -> float:
	var total: float = 0.0
	for item_instance in equipped_items.values():
		total += item_instance.definition.max_hp_bonus
	return total

func get_armor_bonus() -> int:
	var total: int = 0
	for item_instance in equipped_items.values():
		total += item_instance.definition.armor_bonus
	return total

func get_attack_bonus() -> float:
	var total: float = 0.0
	for item_instance in equipped_items.values():
		total += item_instance.definition.attack_bonus
	return total

func get_crit_chance_bonus() -> float:
	var total: float = 0.0
	for item_instance in equipped_items.values():
		total += item_instance.definition.crit_chance_bonus
	return total

func get_crit_damage_bonus() -> float:
	var total: float = 0.0
	for item_instance in equipped_items.values():
		total += item_instance.definition.crit_damage_bonus
	return total
