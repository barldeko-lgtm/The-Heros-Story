class_name Equipment
extends RefCounted

var equipped_items: Dictionary = {}

func equip_if_empty(item_instance) -> bool:
	if item_instance == null or item_instance.definition == null:
		return false
	var slot: String = item_instance.definition.equipment_slot
	if slot.is_empty() or equipped_items.has(slot):
		return false
	if _is_two_handed(item_instance) and equipped_items.has("shield"):
		return false
	if slot == "shield" and _current_weapon_is_two_handed():
		return false
	equipped_items[slot] = item_instance
	return true

func replace_item(item_instance, target_slot: String = ""):
	var displaced: Array = replace_item_configuration(item_instance, target_slot)
	return displaced[0] if not displaced.is_empty() else null

func replace_item_configuration(item_instance, target_slot: String = "") -> Array:
	var displaced: Array = []
	if item_instance == null or item_instance.definition == null:
		return displaced
	var slot: String = resolve_target_slot(item_instance, target_slot)
	if slot.is_empty():
		return displaced
	if _is_two_handed(item_instance):
		_append_removed_item(displaced, "weapon", item_instance)
		_append_removed_item(displaced, "shield", item_instance)
		equipped_items["weapon"] = item_instance
		return displaced
	if slot == "shield" and _current_weapon_is_two_handed():
		_append_removed_item(displaced, "weapon", item_instance)
	_append_removed_item(displaced, slot, item_instance)
	equipped_items[slot] = item_instance
	return displaced

func get_item(slot: String):
	return equipped_items.get(slot)

func get_all_items() -> Array:
	return equipped_items.values()

func duplicate_with_replacement(item_instance, target_slot: String = ""):
	var equipment_copy = get_script().new()
	equipment_copy.equipped_items = equipped_items.duplicate()
	if item_instance != null and item_instance.definition != null:
		equipment_copy.replace_item_configuration(item_instance, target_slot)
	return equipment_copy

func resolve_target_slot(item_instance, requested_slot: String = "") -> String:
	if item_instance == null or item_instance.definition == null:
		return ""
	var authored_slot: String = item_instance.definition.equipment_slot
	var target_slot: String = authored_slot if requested_slot.is_empty() else requested_slot
	if authored_slot in ["ring_1", "ring_2"]:
		return target_slot if target_slot in ["ring_1", "ring_2"] else ""
	if _is_two_handed(item_instance):
		return "weapon" if target_slot == "weapon" else ""
	return target_slot if target_slot == authored_slot else ""

func _append_removed_item(displaced: Array, slot: String, replacement_item) -> void:
	if not equipped_items.has(slot):
		return
	var previous_item = equipped_items[slot]
	equipped_items.erase(slot)
	if previous_item != null and previous_item != replacement_item and not displaced.has(previous_item):
		displaced.append(previous_item)

func _current_weapon_is_two_handed() -> bool:
	return _is_two_handed(equipped_items.get("weapon"))

func _is_two_handed(item_instance) -> bool:
	return item_instance != null \
		and item_instance.definition != null \
		and item_instance.definition.has_method("is_two_handed_weapon") \
		and item_instance.definition.is_two_handed_weapon()

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
