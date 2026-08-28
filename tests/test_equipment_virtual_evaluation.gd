extends SceneTree

const UNCOMMON_HELMET_PATH := "res://data/items/visual_families/ironward_vanguard/boar_helmet_uncommon.tres"

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

	print("PASS: Virtual equip replaces stronger same-rarity items, rejects weaker/equal items, and exposes both HeroPower values.")
	quit()
