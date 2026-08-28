class_name EquipmentEvaluator
extends RefCounted

const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const POWER_EPSILON: float = 0.000001

var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()

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
	result["should_equip"] = result["candidate_power"] > result["current_power"] + POWER_EPSILON
	return result
