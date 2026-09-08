class_name SkillTrainingSystem
extends RefCounted

const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")

const SKILL_ORDER := [
	HeroProgressionScript.POWER_STRIKE_SKILL_ID,
	HeroProgressionScript.BATTLE_GUARD_SKILL_ID,
]
const SKILL_LEVEL_PROPERTIES := {
	HeroProgressionScript.POWER_STRIKE_SKILL_ID: "power_strike_skill_level",
	HeroProgressionScript.BATTLE_GUARD_SKILL_ID: "battle_guard_skill_level",
}
const RANK_COSTS := [0, 0, 500, 650, 850, 1100, 1450, 1900, 2450, 3200, 4150]

var hero_progression

func _init(initial_hero_progression = null) -> void:
	hero_progression = initial_hero_progression if initial_hero_progression != null else HeroProgressionScript.new()

func get_rank_cost(skill_level: int) -> int:
	if skill_level < 2 or skill_level >= RANK_COSTS.size():
		return -1
	return int(RANK_COSTS[skill_level])

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
		var price: int = get_rank_cost(next_level)
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
