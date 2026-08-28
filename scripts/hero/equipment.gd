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

func duplicate_with_replacement(item_instance):
	var equipment_copy = get_script().new()
	equipment_copy.equipped_items = equipped_items.duplicate()
	if item_instance != null and item_instance.definition != null:
		equipment_copy.equipped_items[item_instance.definition.equipment_slot] = item_instance
	return equipment_copy

func get_stat_bonus(stat_id: String) -> float:
	var total: float = 0.0
	for item_instance in equipped_items.values():
		if item_instance != null and item_instance.has_method("get_stat_bonus"):
			total += item_instance.get_stat_bonus(stat_id)
	return total

func get_strength_bonus() -> int:
	return int(get_stat_bonus("strength"))

func get_max_hp_bonus() -> float:
	return get_stat_bonus("max_hp")

func get_armor_bonus() -> float:
	return get_stat_bonus("armor")

func get_attack_bonus() -> float:
	return get_stat_bonus("attack")

func get_attack_speed_bonus() -> float:
	return get_stat_bonus("attack_speed")

func get_accuracy_bonus() -> float:
	return get_stat_bonus("accuracy")

func get_dodge_bonus() -> float:
	return get_stat_bonus("dodge")

func get_fire_resistance_bonus() -> float:
	return get_stat_bonus("fire_resistance")

func get_cold_resistance_bonus() -> float:
	return get_stat_bonus("cold_resistance")

func get_lightning_resistance_bonus() -> float:
	return get_stat_bonus("lightning_resistance")

func get_block_bonus() -> float:
	return get_stat_bonus("block")

func get_crit_chance_bonus() -> float:
	return get_stat_bonus("crit_chance")

func get_crit_damage_bonus() -> float:
	return get_stat_bonus("crit_damage")
