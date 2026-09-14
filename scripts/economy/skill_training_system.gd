class_name SkillTrainingSystem
extends RefCounted

const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")

const SKILL_ORDER := [
	HeroProgressionScript.POWER_STRIKE_SKILL_ID,
	HeroProgressionScript.BATTLE_GUARD_SKILL_ID,
	HeroProgressionScript.SHIELD_BASH_SKILL_ID,
	HeroProgressionScript.CRIPPLING_BLOWS_SKILL_ID,
]
const SKILL_LEVEL_PROPERTIES := {
	HeroProgressionScript.POWER_STRIKE_SKILL_ID: "power_strike_skill_level",
	HeroProgressionScript.BATTLE_GUARD_SKILL_ID: "battle_guard_skill_level",
	HeroProgressionScript.SHIELD_BASH_SKILL_ID: "shield_bash_skill_level",
	HeroProgressionScript.CRIPPLING_BLOWS_SKILL_ID: "crippling_blows_skill_level",
}
const BASE_RANK_COSTS_BY_HERO_LEVEL := {
	10: 500,
	15: 650,
	20: 850,
	25: 1100,
	30: 1450,
	35: 1900,
	40: 2450,
	45: 3200,
	50: 4150,
	55: 5400,
}
const SPECIALIZATION_RANK_COSTS_BY_HERO_LEVEL := {
	30: 1600,
	35: 2100,
	40: 2750,
	45: 3600,
	50: 4700,
	55: 6100,
	60: 7950,
	65: 10350,
	70: 13450,
}

var hero_progression

func _init(initial_hero_progression = null) -> void:
	hero_progression = initial_hero_progression if initial_hero_progression != null else HeroProgressionScript.new()

func get_rank_cost(skill_level: int, skill_id: String = "") -> int:
	if skill_level < 2 or skill_level > HeroProgressionScript.MAX_SKILL_LEVEL:
		return -1
	if skill_id in [HeroProgressionScript.SHIELD_BASH_SKILL_ID, HeroProgressionScript.CRIPPLING_BLOWS_SKILL_ID]:
		var specialization_unlock_level: int = hero_progression.get_skill_unlock_level(skill_id) + (skill_level - 1) * HeroProgressionScript.SKILL_LEVEL_INTERVAL
		return int(SPECIALIZATION_RANK_COSTS_BY_HERO_LEVEL.get(specialization_unlock_level, -1))
	var resolved_skill_id: String = skill_id if not skill_id.is_empty() else HeroProgressionScript.POWER_STRIKE_SKILL_ID
	if resolved_skill_id not in [HeroProgressionScript.POWER_STRIKE_SKILL_ID, HeroProgressionScript.BATTLE_GUARD_SKILL_ID]:
		return -1
	var base_unlock_level: int = hero_progression.get_skill_unlock_level(resolved_skill_id)
	var rank_unlock_level: int = base_unlock_level + (skill_level - 1) * HeroProgressionScript.SKILL_LEVEL_INTERVAL
	return int(BASE_RANK_COSTS_BY_HERO_LEVEL.get(rank_unlock_level, -1))

func get_available_upgrades(hero_state) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if hero_state == null:
		return result

	for skill_id in SKILL_ORDER:
		var property_name: String = str(SKILL_LEVEL_PROPERTIES[skill_id])
		var current_level: int = int(hero_state.get(property_name))
		if current_level <= 0:
			continue
		var max_unlocked_level: int = hero_progression.get_max_unlocked_skill_level(skill_id, hero_state.level)
		if current_level >= max_unlocked_level or current_level >= HeroProgressionScript.MAX_SKILL_LEVEL:
			continue
		var next_level: int = current_level + 1
		var price: int = get_rank_cost(next_level, skill_id)
		if price < 0:
			continue
		result.append({
			"skill_id": skill_id,
			"property_name": property_name,
			"current_level": current_level,
			"next_level": next_level,
			"max_unlocked_level": max_unlocked_level,
			"price": price,
		})
	return result

func select_affordable_upgrade(hero_state, available_gold_override: int = -1) -> Dictionary:
	if hero_state == null:
		return {}
	var available_gold: int = hero_state.gold if available_gold_override < 0 else mini(hero_state.gold, available_gold_override)
	for candidate in get_available_upgrades(hero_state):
		if int(candidate["price"]) <= available_gold:
			return candidate
	return {}

func purchase_next_affordable_upgrade(hero_state, available_gold_override: int = -1) -> Dictionary:
	var candidate: Dictionary = select_affordable_upgrade(hero_state, available_gold_override)
	if candidate.is_empty():
		return {}

	var price: int = int(candidate["price"])
	var property_name: String = str(candidate["property_name"])
	var previous_level: int = int(candidate["current_level"])
	var next_level: int = int(candidate["next_level"])
	if price > hero_state.gold:
		return {}

	hero_state.gold -= price
	hero_state.set(property_name, next_level)
	return {
		"purchased": true,
		"purchase_kind": "skill",
		"skill_id": str(candidate["skill_id"]),
		"previous_level": previous_level,
		"new_level": next_level,
		"price_paid": price,
		"item_instance": null,
		"replaced_item": null,
		"replaced_item_sale_value": 0,
		"power_gain": 0.0,
	}
