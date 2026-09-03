extends SceneTree

const GENERATOR_PATH := "res://scripts/items/item_generator.gd"
const BUDGET_TABLE_PATH := "res://data/items/balance/item_modifier_budget_table.tres"
const STAT_COST_TABLE_PATH := "res://data/items/balance/item_modifier_stat_costs.tres"
const BASE_STAT_TABLE_PATH := "res://data/items/balance/item_base_stat_table.tres"
const COMMON_HELMET_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_helmet.tres"
const UNCOMMON_HELMET_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_helmet_uncommon.tres"
const RARE_SWORD_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_sword_rare.tres"
const GOBLIN_PATH := "res://data/mobs/0001_goblin.tres"

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
	var generator_script: Script = load(GENERATOR_PATH)
	var budget_table: Resource = load(BUDGET_TABLE_PATH)
	var stat_costs: Resource = load(STAT_COST_TABLE_PATH)
	var base_stats: Resource = load(BASE_STAT_TABLE_PATH)
	if generator_script == null or budget_table == null or stat_costs == null or base_stats == null:
		push_error("The item generator and all current Scope balance tables must load.")
		quit(1)
		return

	assert(is_equal_approx(budget_table.get_green_affix_budget(10), 78.0), "ilvl 10 Green affix budget must be 78.")
	assert(budget_table.get_affix_count(0) == 0 and budget_table.get_affix_count(1) == 1 and budget_table.get_affix_count(2) == 2, "Current rarities must create 0/1/2 affixes.")
	assert(is_equal_approx(budget_table.get_per_affix_multiplier(2), 0.85), "Rare affixes must each use 85% of the Green budget.")
	assert(is_equal_approx(stat_costs.get_stat_cost("health"), 4.0), "Health must cost 4 budget.")
	assert(is_equal_approx(stat_costs.get_stat_cost("block"), 13.0), "Block must cost 13 budget.")
	assert(is_equal_approx(base_stats.get_armor(10), 7.0), "ilvl 10 armor must have 7 base Armor.")
	assert(is_equal_approx(base_stats.get_sword_damage(10), 13.0), "ilvl 10 sword must have 13 base Damage.")
	assert(is_equal_approx(base_stats.get_shield_block(10), 13.0), "ilvl 10 shield must have 13 base Block.")

	var generator = generator_script.new(budget_table, stat_costs, base_stats)
	var common_helmet = generator.generate(load(COMMON_HELMET_PATH), 10, ScriptedRng.new())
	assert(common_helmet.item_level == 10 and common_helmet.rarity == 0, "Generated Common equipment must store ilvl and rarity on ItemInstance.")
	assert(common_helmet.affixes.is_empty() and is_zero_approx(common_helmet.rolled_total_modifier_budget), "Common equipment must have no modifier budget or affixes.")
	assert(is_equal_approx(common_helmet.get_stat_bonus("armor"), 7.0), "Common ilvl 10 armor must keep its inherent 7 Armor.")
	assert(is_zero_approx(common_helmet.get_stat_bonus("strength")), "Generated equipment must not preserve the experimental Strength bonus.")

	var uncommon_helmet = generator.generate(load(UNCOMMON_HELMET_PATH), 10, ScriptedRng.new([0.5], [0]))
	assert(uncommon_helmet.affixes.size() == 1, "Uncommon equipment must roll exactly one affix.")
	assert(is_equal_approx(uncommon_helmet.rolled_total_modifier_budget, 78.0), "A midpoint ilvl 10 Uncommon roll must keep the nominal 78 budget.")
	assert(uncommon_helmet.affixes[0]["stat_id"] == "health", "The scripted armor affix roll must select Health.")
	assert(is_equal_approx(uncommon_helmet.affixes[0]["budget"], 78.0), "The single Uncommon affix must receive the full rolled budget.")
	assert(is_equal_approx(uncommon_helmet.affixes[0]["value"], 78.0 / 4.0), "Affix value must equal assigned budget divided by stat cost.")
	assert(is_equal_approx(uncommon_helmet.get_stat_bonus("max_hp"), 78.0 / 4.0), "Generated Health must enter resolved item stats.")

	var rare_sword = generator.generate(load(RARE_SWORD_PATH), 10, ScriptedRng.new([0.5], [0, 0]))
	var expected_rare_total: float = 78.0 * 0.85 * 2.0
	assert(rare_sword.affixes.size() == 2, "Rare equipment must roll exactly two affixes.")
	assert(rare_sword.affixes[0]["stat_id"] != rare_sword.affixes[1]["stat_id"], "One item must not repeat a random affix.")
	assert(is_equal_approx(rare_sword.rolled_total_modifier_budget, expected_rare_total), "Rare total budget must contain two 85% affixes before the midpoint roll.")
	assert(is_equal_approx(rare_sword.affixes[0]["budget"], expected_rare_total / 2.0), "Rare budget must split equally between both affixes.")
	assert(is_equal_approx(rare_sword.get_stat_bonus("attack_speed"), 0.10), "Every ilvl 10 sword rarity must retain the inherent +0.10 Attack Speed.")
	assert(rare_sword.get_item_power() > 0.0, "Generated base stats and affixes must contribute to ItemPower.")
	assert(rare_sword.get_tooltip_text().contains("Уровень предмета: 10"), "Generated-item tooltip must display Item Level.")

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	var starting_armor: float = simulation.base_combat_stats.armor
	var starting_hp: float = simulation.base_combat_stats.max_hp
	var drop_result: Dictionary = simulation.resolve_mob_equipment_drop(
		load(GOBLIN_PATH),
		1,
		ScriptedRng.new([0.0, 0.70, 0.5], [0, 0])
	)
	var dropped_item = drop_result.get("item_instance")
	assert(dropped_item != null and dropped_item.item_level == 1 and dropped_item.rarity == 1, "Goblin must generate an ilvl 1 Rustchain Initiate ItemInstance.")
	assert(drop_result["equipped"], "The first generated item for an empty slot must reach current equipment.")
	assert(is_equal_approx(simulation.base_combat_stats.armor, starting_armor + 5.0), "Generated ilvl 1 inherent Armor must flow through Equipment and StatResolver.")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, starting_hp + 60.0 / 4.0), "Generated ilvl 1 Health affix must flow through Equipment and StatResolver.")

	print("PASS: Shared generation supports direct ilvl 10 items and source-driven ilvl 1 Goblin equipment with resolved hero stats.")
	quit()
