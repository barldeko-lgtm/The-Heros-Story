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
	var generated: Dictionary = generate_mob_equipment_drop(mob_definition, rng)
	var item_instance = generated.get("item_instance")
	if item_instance == null:
		var empty_result: Dictionary = create_empty_routing_result()
		empty_result["item_definition"] = generated.get("item_definition")
		return empty_result
	var result: Dictionary = route_item(hero_state, item_instance)
	result["item_definition"] = generated.get("item_definition")
	return result

func generate_mob_equipment_drop(mob_definition: Resource, rng) -> Dictionary:
	var result: Dictionary = {
		"item_definition": null,
		"item_instance": null,
	}
	if mob_definition == null or rng == null or mob_definition.equipment_drop_table == null:
		return result
	var item_definition = loot_generator.roll_mob_equipment(mob_definition, rng)
	if item_definition == null:
		return result
	var item_level: int = int(mob_definition.equipment_drop_table.item_level)
	result["item_definition"] = item_definition
	result["item_instance"] = item_generator.generate(item_definition, item_level, rng)
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

func resolve_authored_source_reward(hero_state, source: Resource, rng, rarity_override: int) -> Dictionary:
	if source == null or rng == null or source.item_level <= 0:
		return {}
	var item_pool: Array[Resource]
	match rarity_override:
		0:
			item_pool = source.common_items
		1:
			item_pool = source.uncommon_items
		_:
			item_pool = source.rare_items
	if item_pool.is_empty():
		return {}
	var item_definition: Resource = item_pool[rng.randi_range(0, item_pool.size() - 1)]
	var result: Dictionary = receive_item(hero_state, item_definition, int(source.item_level), rng, rarity_override)
	result["item_definition"] = item_definition
	result["rolled_rarity"] = rarity_override
	return result

func receive_item(hero_state, item_definition: Resource, item_level: int, rng, rarity_override: int = -1) -> Dictionary:
	var result: Dictionary = create_empty_routing_result()
	if hero_state == null or item_definition == null or rng == null:
		return result

	var item_instance = item_generator.generate(item_definition, item_level, rng, rarity_override)
	if item_instance == null:
		return result
	return route_item(hero_state, item_instance)

func route_item(hero_state, item_instance) -> Dictionary:
	var result: Dictionary = create_empty_routing_result()
	if hero_state == null or item_instance == null or item_instance.definition == null:
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

func create_empty_routing_result() -> Dictionary:
	return {
		"item_instance": null,
		"equipment_evaluation": {},
		"equipped": false,
		"inventory_item": null,
		"dropped_item": null,
		"target_slot": "",
	}
