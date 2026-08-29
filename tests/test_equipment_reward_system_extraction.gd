extends SceneTree

const REWARD_SYSTEM_PATH := "res://scripts/loot/equipment_reward_system.gd"
const COMMON_CHEST_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres"

func _init() -> void:
	var reward_system_script: Script = load(REWARD_SYSTEM_PATH)
	if reward_system_script == null:
		push_error("EquipmentRewardSystem must exist as the owner of equipment reward routing.")
		quit(1)
		return

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var common_chest: Resource = load(COMMON_CHEST_PATH)
	assert(simulation_script != null and common_chest != null, "Reward-routing test inputs must load.")

	var direct_simulation = simulation_script.new(1)
	var reward_system = reward_system_script.new(direct_simulation.loot_generator, direct_simulation.item_generator, direct_simulation.equipment_evaluator)
	var direct_result: Dictionary = reward_system.receive_item(direct_simulation.hero_state, common_chest, 10, direct_simulation.seeded_rng.get_rng())
	assert(direct_result["equipped"], "The reward system must equip an upgrade into an empty slot.")
	assert(direct_simulation.hero_state.equipment.get_item("chest") == direct_result["item_instance"], "The reward system must own equipment mutation for an approved reward.")

	var compatibility_simulation = simulation_script.new(1)
	var previous_max_hp: float = compatibility_simulation.combat_stats.max_hp
	var compatibility_result: Dictionary = compatibility_simulation.receive_item_reward(common_chest, 7, 10)
	assert(compatibility_result["equipped"], "Simulation.receive_item_reward must remain a compatible public wrapper.")
	assert(compatibility_simulation.hero_state.equipment.get_item("chest") == compatibility_result["item_instance"], "The compatibility wrapper must route through the extracted reward system.")
	assert(compatibility_simulation.combat_stats.max_hp >= previous_max_hp, "The compatibility wrapper must keep resolved combat stats synchronized.")

	print("PASS: Equipment reward routing is extracted while Simulation keeps its compatible public entry point.")
	quit()
