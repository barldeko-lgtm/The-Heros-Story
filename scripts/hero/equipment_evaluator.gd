class_name EquipmentEvaluator
extends RefCounted

const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const BeltPotionRulesScript = preload("res://scripts/items/belt_potion_rules.gd")
const POWER_EPSILON: float = 0.000001

var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()
var belt_potion_rules = BeltPotionRulesScript.new()

func evaluate(hero_state, candidate_item) -> Dictionary:
	var result: Dictionary = {
		"should_equip": false,
		"current_power": 0.0,
		"candidate_power": 0.0,
	}
	if hero_state == null or candidate_item == null or candidate_item.definition == null:
		return result

	var current_stats = stat_resolver.resolve(hero_state, false)
	var candidate_equipment = hero_state.equipment.duplicate_with_replacement(candidate_item)
	var candidate_stats = stat_resolver.resolve(hero_state, false, candidate_equipment)
	result["current_power"] = power_calculator.calculate(current_stats)
	result["candidate_power"] = power_calculator.calculate(candidate_stats)
	if candidate_item.definition.equipment_slot == "belt":
		var current_belt = hero_state.equipment.get_item("belt")
		var current_healing: float = belt_potion_rules.get_potential_healing(current_belt)
		var candidate_healing: float = belt_potion_rules.get_potential_healing(candidate_item)
		var current_health: float = 0.0 if current_belt == null else current_belt.get_stat_bonus("max_hp")
		var candidate_health: float = candidate_item.get_stat_bonus("max_hp")
		result["comparison_mode"] = "belt_utility"
		result["current_belt_healing"] = current_healing
		result["candidate_belt_healing"] = candidate_healing
		result["current_belt_health"] = current_health
		result["candidate_belt_health"] = candidate_health
		result["should_equip"] = current_belt == null \
			or candidate_healing > current_healing + POWER_EPSILON \
			or (is_equal_approx(candidate_healing, current_healing) and candidate_health > current_health + POWER_EPSILON)
		return result
	result["should_equip"] = result["candidate_power"] > result["current_power"] + POWER_EPSILON
	return result
