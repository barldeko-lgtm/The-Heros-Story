class_name EquipmentRewardSystem
extends RefCounted

var loot_generator
var item_generator
var equipment_evaluator

func _init(initial_loot_generator, initial_item_generator, initial_equipment_evaluator) -> void:
	loot_generator = initial_loot_generator
	item_generator = initial_item_generator
	equipment_evaluator = initial_equipment_evaluator

func resolve_mob_equipment_drop(hero_state, mob_definition: Resource, rng) -> Dictionary:
	var result: Dictionary = {
		"item_definition": null,
		"item_instance": null,
		"equipped": false,
		"inventory_item": null,
		"dropped_item": null,
	}
	var item_definition = loot_generator.roll_mob_equipment(mob_definition, rng)
	if item_definition == null:
		return result
	var item_level: int = int(mob_definition.equipment_drop_table.item_level)
	result = receive_item(hero_state, item_definition, item_level, rng)
	result["item_definition"] = item_definition
	return result

func receive_item(hero_state, item_definition: Resource, item_level: int, rng) -> Dictionary:
	var result: Dictionary = {
		"item_instance": null,
		"equipment_evaluation": {},
		"equipped": false,
		"inventory_item": null,
		"dropped_item": null,
	}
	if hero_state == null or item_definition == null or rng == null:
		return result

	var item_instance = item_generator.generate(item_definition, item_level, rng)
	if item_instance == null:
		return result
	result["item_instance"] = item_instance

	var evaluation: Dictionary = equipment_evaluator.evaluate(hero_state, item_instance)
	result["equipment_evaluation"] = evaluation
	if bool(evaluation.get("should_equip", false)):
		var replaced_item = hero_state.equipment.replace_item(item_instance)
		if replaced_item != null:
			result["inventory_item"] = replaced_item
			result["dropped_item"] = hero_state.inventory.add_item(replaced_item)
		result["equipped"] = true
	else:
		result["inventory_item"] = item_instance
		result["dropped_item"] = hero_state.inventory.add_item(item_instance)
	return result
