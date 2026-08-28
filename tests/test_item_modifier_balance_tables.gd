extends SceneTree

const BUDGET_TABLE_PATH := "res://data/items/balance/item_modifier_budget_table.tres"
const STAT_COST_TABLE_PATH := "res://data/items/balance/item_modifier_stat_costs.tres"
const BASE_STAT_TABLE_PATH := "res://data/items/balance/item_base_stat_table.tres"

func _init() -> void:
	var budget_table: Resource = load(BUDGET_TABLE_PATH)
	var stat_costs: Resource = load(STAT_COST_TABLE_PATH)
	var base_stats: Resource = load(BASE_STAT_TABLE_PATH)
	assert(budget_table != null and stat_costs != null and base_stats != null, "Current item balance resources must load.")

	var expected_green_budgets := {1: 60.0, 10: 78.0, 20: 101.0, 30: 132.0, 40: 171.0, 50: 223.0, 60: 290.0}
	for item_level in expected_green_budgets:
		assert(is_equal_approx(budget_table.get_green_affix_budget(item_level), expected_green_budgets[item_level]), "Green affix budget must match the current Scope.")
	assert(is_equal_approx(budget_table.get_per_affix_multiplier(1), 1.0), "Uncommon per-affix multiplier must be 1.0.")
	assert(is_equal_approx(budget_table.get_per_affix_multiplier(2), 0.85), "Rare per-affix multiplier must be 0.85.")
	assert(is_equal_approx(budget_table.get_per_affix_multiplier(3), 0.7225), "Epic per-affix multiplier must be 0.7225.")
	assert(is_equal_approx(budget_table.total_budget_roll_min, 0.95) and is_equal_approx(budget_table.total_budget_roll_max, 1.05), "One item-wide budget roll must use +/-5%.")

	var expected_costs := {
		"health": 4.0,
		"armor": 12.0,
		"dodge": 12.0,
		"accuracy": 1.0,
		"damage": 18.0,
		"crit_chance_percentage_point": 40.0,
		"crit_damage_percentage_point": 7.0,
		"attack_speed_percent": 30.0,
		"cast_speed_percent": 30.0,
		"elemental_resistance": 5.0,
		"block": 13.0,
	}
	for stat_id in expected_costs:
		assert(is_equal_approx(stat_costs.get_stat_cost(stat_id), expected_costs[stat_id]), "Modifier cost must match the current Scope for %s." % stat_id)

	assert(is_equal_approx(base_stats.get_armor(10), 7.0), "ilvl 10 armor base Armor must be 7.")
	assert(is_equal_approx(base_stats.get_sword_damage(10), 13.0), "ilvl 10 sword base Damage must be 13.")
	assert(is_equal_approx(base_stats.get_sword_attack_speed_bonus(10), 0.10), "Sword base Attack Speed bonus must remain +0.10.")
	assert(is_equal_approx(base_stats.get_shield_block(10), 13.0), "ilvl 10 shield base Block must be 13.")

	print("PASS: Item modifier budgets, base stats, and stat costs match the current Prototype 0.2 Scope.")
	quit()
