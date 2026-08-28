extends SceneTree

const COMMON_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres"
const UNCOMMON_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate_uncommon.tres"
const RARE_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres"
const BOAR_QUEST_PATH := "res://data/quests/0005_boars_in_fields.tres"

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var common: Resource = load(COMMON_PATH)
	var uncommon: Resource = load(UNCOMMON_PATH)
	var rare: Resource = load(RARE_PATH)
	var boar_quest: Resource = load(BOAR_QUEST_PATH)
	assert(simulation_script != null and common != null and uncommon != null and rare != null and boar_quest != null, "All quality reward resources must load.")
	assert(boar_quest.item_reward_pool.size() == 3, "Boar quest must contain exactly three equally selectable qualities.")

	var simulation = simulation_script.new(1)
	var starting_max_hp: float = simulation.base_combat_stats.max_hp
	var starting_attack: float = simulation.base_combat_stats.attack

	var common_result: Dictionary = simulation.receive_item_reward(common, 1)
	assert(common_result["equipped"], "The first chestplate must equip into the empty slot.")
	assert(simulation.hero_state.equipment.get_item("chest").definition.quality == 0, "Common chestplate must be equipped first.")

	var duplicate_common_result: Dictionary = simulation.receive_item_reward(common, 2)
	assert(not duplicate_common_result["equipped"], "Equal quality must go to inventory.")
	assert(simulation.hero_state.inventory.get_items().size() == 1, "Equal quality reward must occupy inventory.")
	var oldest_inventory_item = simulation.hero_state.inventory.get_items()[0]

	var uncommon_result: Dictionary = simulation.receive_item_reward(uncommon, 3)
	assert(uncommon_result["equipped"], "Better uncommon quality must replace common equipment.")
	assert(simulation.hero_state.equipment.get_item("chest").definition.quality == 1, "Uncommon chestplate must be equipped.")
	assert(simulation.hero_state.inventory.get_items().size() == 2, "Replaced common equipment must move to inventory.")

	var rare_result: Dictionary = simulation.receive_item_reward(rare, 4)
	assert(rare_result["equipped"], "Better rare quality must replace uncommon equipment.")
	assert(simulation.hero_state.equipment.get_item("chest").definition.quality == 2, "Rare chestplate must be equipped.")
	assert(simulation.hero_state.inventory.get_items().size() == 3, "Replaced uncommon equipment must move to inventory.")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, starting_max_hp + 35.0), "Rare armor must add its direct 35 MaxHP.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, starting_attack + 6.0), "Rare +3 Strength must add 6 physical Damage.")
	assert(is_equal_approx(simulation.base_combat_stats.armor, 25.0), "Rare 20 Armor plus starting Constitution must resolve to 25 Armor.")

	var last_result: Dictionary = {}
	for reward_index in 34:
		last_result = simulation.receive_item_reward(common, 5 + reward_index)
	assert(simulation.hero_state.inventory.get_items().size() == 36, "Inventory must retain exactly 36 items.")
	assert(last_result["dropped_item"] == oldest_inventory_item, "Adding item 37 must drop the oldest inventory item.")
	assert(not simulation.hero_state.inventory.get_items().has(oldest_inventory_item), "Dropped oldest item must leave inventory.")

	var seen_qualities: Dictionary = {}
	for roll_index in 120:
		var rolled_definition = simulation.roll_quest_item_reward(boar_quest)
		seen_qualities[rolled_definition.quality] = true
	assert(seen_qualities.size() == 3, "Seeded equal-third rolls must be able to produce every quality.")

	print("PASS: Boar quality rewards upgrade equipment and use FIFO inventory overflow.")
	quit()
