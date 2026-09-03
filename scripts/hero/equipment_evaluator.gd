class_name EquipmentEvaluator
extends RefCounted

const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const BeltPotionRulesScript = preload("res://scripts/items/belt_potion_rules.gd")
const POWER_EPSILON: float = 0.000001
const RING_SLOTS: Array[String] = ["ring_1", "ring_2"]

var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()
var belt_potion_rules = BeltPotionRulesScript.new()

func evaluate(hero_state, candidate_item) -> Dictionary:
	var result: Dictionary = {
		"should_equip": false,
		"current_power": 0.0,
		"candidate_power": 0.0,
		"target_slot": "",
	}
	if hero_state == null or candidate_item == null or candidate_item.definition == null:
		return result

	var current_stats = stat_resolver.resolve(hero_state, false)
	result["current_power"] = power_calculator.calculate(current_stats)
	var authored_slot: String = candidate_item.definition.equipment_slot
	var target_slots: Array[String] = [authored_slot]
	if authored_slot in RING_SLOTS:
		var alternate_ring_slot: String = "ring_2" if authored_slot == "ring_1" else "ring_1"
		target_slots.append(alternate_ring_slot)

	var best_target_slot: String = authored_slot
	var best_candidate_power: float = -INF
	for target_slot in target_slots:
		var candidate_equipment = hero_state.equipment.duplicate_with_replacement(candidate_item, target_slot)
		var candidate_stats = stat_resolver.resolve(hero_state, false, candidate_equipment)
		var candidate_power: float = power_calculator.calculate(candidate_stats)
		if candidate_power > best_candidate_power + POWER_EPSILON:
			best_candidate_power = candidate_power
			best_target_slot = target_slot

	result["candidate_power"] = best_candidate_power
	result["target_slot"] = best_target_slot
	if authored_slot in RING_SLOTS:
		result["comparison_mode"] = "ring_pair"
	if authored_slot == "belt":
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
