extends SceneTree

const UNCOMMON_HELMET_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_helmet_uncommon.tres"
const ItemInstanceScript = preload("res://scripts/model/runtime/item_instance.gd")

class FixedItemGenerator:
	extends RefCounted

	var fixed_item

	func _init(item_instance) -> void:
		fixed_item = item_instance

	func generate(_item_definition: Resource, _item_level: int, _rng, _rarity_override: int = -1):
		return fixed_item

class ScriptedRng:
	extends RefCounted

	var float_values: Array = []
	var int_values: Array = []

	func _init(initial_float_values: Array = [], initial_int_values: Array = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		assert(not float_values.is_empty(), "Scripted RNG ran out of float values.")
		return float(float_values.pop_front())

	func randi_range(from: int, to: int) -> int:
		assert(not int_values.is_empty(), "Scripted RNG ran out of integer values.")
		var value: int = int(int_values.pop_front())
		assert(value >= from and value <= to, "Scripted integer roll must stay inside the requested range.")
		return value

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var uncommon_helmet: Resource = load(UNCOMMON_HELMET_PATH)
	assert(simulation_script != null and uncommon_helmet != null, "Virtual-equip integration inputs must load.")

	var simulation = simulation_script.new(1)
	var weak_result: Dictionary = simulation.receive_item_reward(uncommon_helmet, 1, 10, ScriptedRng.new([0.0], [0]))
	var weak_item = weak_result["item_instance"]
	assert(weak_result["equipped"] and weak_item != null, "The first item for an empty slot must equip.")
	var weak_power: float = simulation.get_hero_power()

	var strong_result: Dictionary = simulation.receive_item_reward(uncommon_helmet, 2, 10, ScriptedRng.new([1.0], [0]))
	if not strong_result["equipped"]:
		push_error("A stronger item of the same rarity must replace the weaker equipped item through virtual equip.")
		quit(1)
		return
	var strong_item = strong_result["item_instance"]
	assert(strong_item != null and strong_item.rarity == weak_item.rarity, "The comparison case must use two items of the same rarity.")
	assert(strong_item.rolled_total_modifier_budget > weak_item.rolled_total_modifier_budget, "The scripted candidate must have the stronger total budget.")
	assert(simulation.hero_state.equipment.get_item("helmet") == strong_item, "The stronger same-rarity candidate must become equipped.")
	assert(simulation.hero_state.inventory.get_items().has(weak_item), "The replaced weaker item must move to Inventory.")
	assert(simulation.get_hero_power() > weak_power, "Equipping the candidate must strictly increase real base HeroPower.")
	assert(strong_result["equipment_evaluation"]["candidate_power"] > strong_result["equipment_evaluation"]["current_power"], "The routing result must expose the real virtual-equip comparison.")

	var weaker_result: Dictionary = simulation.receive_item_reward(uncommon_helmet, 3, 10, ScriptedRng.new([0.0], [0]))
	assert(not weaker_result["equipped"], "A weaker candidate of the same rarity must stay unequipped.")
	assert(simulation.hero_state.equipment.get_item("helmet") == strong_item, "Rejecting a weaker candidate must not mutate equipped state.")
	assert(simulation.hero_state.inventory.get_items().has(weaker_result["item_instance"]), "Rejected generated equipment must enter Inventory.")

	var equal_result: Dictionary = simulation.receive_item_reward(uncommon_helmet, 4, 10, ScriptedRng.new([1.0], [0]))
	assert(not equal_result["equipped"], "Equal HeroPower must keep the existing item and avoid equipment churn.")
	assert(is_equal_approx(equal_result["equipment_evaluation"]["candidate_power"], equal_result["equipment_evaluation"]["current_power"]), "Equal generated items must produce equal virtual HeroPower.")
	assert(simulation.hero_state.equipment.get_item("helmet") == strong_item, "An equal candidate must not replace the existing instance.")

	test_ring_candidate_replaces_weaker_of_two_slots(simulation_script)

	print("PASS: Virtual equip replaces stronger same-rarity items, rejects weaker/equal items, and evaluates ring candidates against both ring slots.")
	quit()

func test_ring_candidate_replaces_weaker_of_two_slots(simulation_script: Script) -> void:
	var simulation = simulation_script.new(41)
	var green_ring_definition: Resource = load("res://data/items/visual_families/ironward_vanguard/ironward_ring_1_uncommon.tres")
	var white_ring_definition: Resource = load("res://data/items/visual_families/ironward_vanguard/ironward_ring_2.tres")
	var blue_ring_definition: Resource = load("res://data/items/visual_families/ironward_vanguard/ironward_ring_1_rare.tres")
	assert(green_ring_definition != null and white_ring_definition != null and blue_ring_definition != null, "Ring pair regression definitions must load.")

	var green_ring = ItemInstanceScript.new(
		green_ring_definition,
		10,
		1,
		{"fire_resistance": 20.0},
		[{"stat_id": "health", "value": 30.0}],
		78.0,
		{"fire_resistance": 20.0, "max_hp": 30.0}
	)
	var white_ring = ItemInstanceScript.new(
		white_ring_definition,
		10,
		0,
		{"cold_resistance": 20.0},
		[],
		0.0,
		{"cold_resistance": 20.0}
	)
	var blue_ring = ItemInstanceScript.new(
		blue_ring_definition,
		10,
		2,
		{"lightning_resistance": 20.0},
		[
			{"stat_id": "health", "value": 50.0},
			{"stat_id": "accuracy", "value": 20.0},
		],
		132.6,
		{"lightning_resistance": 20.0, "max_hp": 50.0, "accuracy": 20.0}
	)

	simulation.hero_state.equipment.replace_item(green_ring, "ring_1")
	simulation.hero_state.equipment.replace_item(white_ring, "ring_2")
	simulation.refresh_combat_stats()
	var evaluation: Dictionary = simulation.equipment_evaluator.evaluate(simulation.hero_state, blue_ring)
	assert(bool(evaluation.get("should_equip", false)), "A stronger Blue ring must be recognized as an upgrade over the current ring pair.")
	assert(str(evaluation.get("target_slot", "")) == "ring_2", "A Ring 1-authored candidate must target Ring 2 when Ring 2 is the weaker equipped ring.")

	simulation.equipment_reward_system.item_generator = FixedItemGenerator.new(blue_ring)
	var reward_result: Dictionary = simulation.receive_item_reward(blue_ring_definition, 100, 10, RandomNumberGenerator.new(), 2)
	assert(bool(reward_result.get("equipped", false)) and str(reward_result.get("target_slot", "")) == "ring_2", "Loot routing must equip the ring into the weaker of the two ring slots.")
	assert(simulation.hero_state.equipment.get_item("ring_1") == green_ring, "The stronger existing Green ring must remain equipped.")
	assert(simulation.hero_state.equipment.get_item("ring_2") == blue_ring, "The new Blue ring must replace the weaker White ring.")
	assert(simulation.hero_state.inventory.get_items().has(white_ring), "The displaced weaker White ring must enter Inventory.")
	assert(not simulation.hero_state.inventory.get_items().has(green_ring), "The stronger Green ring must not be displaced merely because the new ring was authored for Ring 1.")
