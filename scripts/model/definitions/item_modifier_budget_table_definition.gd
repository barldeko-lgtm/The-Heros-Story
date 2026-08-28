class_name ItemModifierBudgetTableDefinition
extends Resource

const RARITY_NORMAL: int = 0
const RARITY_UNCOMMON: int = 1
const RARITY_RARE: int = 2
const RARITY_EPIC: int = 3

@export var item_levels: Array[int] = []
@export var green_affix_budgets: Array[float] = []
@export var uncommon_affix_multiplier: float = 1.0
@export var rare_affix_multiplier: float = 0.85
@export var epic_affix_multiplier: float = 0.7225
@export var total_budget_roll_min: float = 0.95
@export var total_budget_roll_max: float = 1.05
@export var adjacent_tier_growth_target: float = 1.30

func get_green_affix_budget(item_level: int) -> float:
	var tier_index: int = item_levels.find(item_level)
	if tier_index < 0 or tier_index >= green_affix_budgets.size():
		return -1.0
	return green_affix_budgets[tier_index]

func get_affix_count(rarity: int) -> int:
	match rarity:
		RARITY_UNCOMMON: return 1
		RARITY_RARE: return 2
		RARITY_EPIC: return 3
	return 0

func get_per_affix_multiplier(rarity: int) -> float:
	match rarity:
		RARITY_UNCOMMON: return uncommon_affix_multiplier
		RARITY_RARE: return rare_affix_multiplier
		RARITY_EPIC: return epic_affix_multiplier
	return 0.0

func get_nominal_total_budget(item_level: int, rarity: int) -> float:
	var green_budget: float = get_green_affix_budget(item_level)
	if green_budget < 0.0:
		return -1.0
	return green_budget * get_per_affix_multiplier(rarity) * get_affix_count(rarity)
