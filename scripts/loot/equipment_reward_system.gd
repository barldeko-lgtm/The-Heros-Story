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

func resolve_dungeon_completion_reward(hero_state, dungeon_definition: Resource, rng) -> Dictionary:
	var roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon_definition, rng)
	if roll.is_empty():
		return {
			"item_definition": null,
			"item_instance": null,
			"equipment_evaluation": {},
			"equipped": false,
			"inventory_item": null,
			"dropped_item": null,
		}
	var item_definition: Resource = roll["item_definition"]
	var result: Dictionary = receive_item(hero_state, item_definition, int(roll["item_level"]), rng, int(roll["rarity"]))
	result["item_definition"] = item_definition
	result["rolled_rarity"] = int(roll["rarity"])
	return result

func receive_item(hero_state, item_definition: Resource, item_level: int, rng, rarity_override: int = -1) -> Dictionary:
	var result: Dictionary = {
		"item_instance": null,
		"equipment_evaluation": {},
		"equipped": false,
		"inventory_item": null,
		"dropped_item": null,
		"target_slot": "",
	}
	if hero_state == null or item_definition == null or rng == null:
		return result

	var item_instance = item_generator.generate(item_definition, item_level, rng, rarity_override)
	if item_instance == null:
		return result
	result["item_instance"] = item_instance

	var evaluation: Dictionary = equipment_evaluator.evaluate(hero_state, item_instance)
	result["equipment_evaluation"] = evaluation
	if bool(evaluation.get("should_equip", false)):
		var target_slot: String = str(evaluation.get("target_slot", item_instance.definition.equipment_slot))
		var replaced_item = hero_state.equipment.replace_item(item_instance, target_slot)
		result["target_slot"] = target_slot
		if replaced_item != null:
			result["inventory_item"] = replaced_item
			result["dropped_item"] = hero_state.inventory.add_item(replaced_item)
		result["equipped"] = true
	else:
		result["inventory_item"] = item_instance
		result["dropped_item"] = hero_state.inventory.add_item(item_instance)
	return result
