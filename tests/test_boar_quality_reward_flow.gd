extends SceneTree

const COMMON_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres"
const UNCOMMON_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate_uncommon.tres"
const RARE_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres"

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var common: Resource = load(COMMON_PATH)
	var uncommon: Resource = load(UNCOMMON_PATH)
	var rare: Resource = load(RARE_PATH)
	assert(simulation_script != null and common != null and uncommon != null and rare != null, "All quality item resources must load.")

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
	var equipped_rare = simulation.hero_state.equipment.get_item("chest")
	assert(equipped_rare.item_level == 10 and equipped_rare.affixes.size() == 2, "Current Rare armor must be generated at ilvl 10 with two affixes.")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, starting_max_hp + equipped_rare.get_stat_bonus("max_hp")), "Generated Health must flow from ItemInstance.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, starting_attack + equipped_rare.get_stat_bonus("attack")), "Generated Damage must flow from ItemInstance.")
	assert(is_equal_approx(simulation.base_combat_stats.armor, 5.0 + equipped_rare.get_stat_bonus("armor")), "Generated inherent and affix Armor must flow from ItemInstance.")

	var last_result: Dictionary = {}
	for reward_index in 34:
		last_result = simulation.receive_item_reward(common, 5 + reward_index)
	assert(simulation.hero_state.inventory.get_items().size() == 36, "Inventory must retain exactly 36 items.")
	assert(last_result["dropped_item"] == oldest_inventory_item, "Adding item 37 must drop the oldest inventory item.")
	assert(not simulation.hero_state.inventory.get_items().has(oldest_inventory_item), "Dropped oldest item must leave inventory.")

	print("PASS: Boar quality items upgrade equipment and use FIFO inventory overflow.")
	quit()
