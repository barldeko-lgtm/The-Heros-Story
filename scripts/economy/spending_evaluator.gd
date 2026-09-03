class_name SpendingEvaluator
extends RefCounted

const EquipmentEvaluatorScript = preload("res://scripts/hero/equipment_evaluator.gd")
const ItemPriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")

const SHOP_ITEMPOWER_THRESHOLD_MULTIPLIER: float = 1.20
const POWER_EPSILON: float = 0.000001

var equipment_evaluator = EquipmentEvaluatorScript.new()
var item_price_calculator = ItemPriceCalculatorScript.new()

func select_best_equipment_purchase(hero_state, listings: Array, available_gold_override: int = -1) -> Dictionary:
	var best_result: Dictionary = {}
	if hero_state == null:
		return best_result
	var available_gold: int = hero_state.gold if available_gold_override < 0 else mini(hero_state.gold, available_gold_override)

	for listing_index in listings.size():
		var listing = listings[listing_index]
		if listing == null:
			continue
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.definition == null:
			continue

		var price: int = item_price_calculator.get_reference_shop_value_for_item(item_instance)
		if price < 0 or price > available_gold:
			continue

		var equipment_evaluation: Dictionary = equipment_evaluator.evaluate(hero_state, item_instance)
		if not bool(equipment_evaluation.get("should_equip", false)):
			continue
		var target_slot: String = str(equipment_evaluation.get("target_slot", item_instance.definition.equipment_slot))
		var current_item = hero_state.equipment.get_item(target_slot)
		var current_item_power: float = 0.0 if current_item == null else current_item.get_item_power()
		var candidate_item_power: float = item_instance.get_item_power()
		var is_belt: bool = item_instance.definition.equipment_slot == "belt"
		if not is_belt and current_item != null and candidate_item_power + POWER_EPSILON < current_item_power * SHOP_ITEMPOWER_THRESHOLD_MULTIPLIER:
			continue

		var power_gain: float = float(equipment_evaluation.get("candidate_power", 0.0)) - float(equipment_evaluation.get("current_power", 0.0))
		if not is_belt and power_gain <= POWER_EPSILON:
			continue

		var candidate_result: Dictionary = {
			"listing_index": listing_index,
			"listing": listing,
			"item_instance": item_instance,
			"price": price,
			"target_slot": target_slot,
			"current_item_power": current_item_power,
			"candidate_item_power": candidate_item_power,
			"power_gain": power_gain,
			"current_power": float(equipment_evaluation.get("current_power", 0.0)),
			"candidate_power": float(equipment_evaluation.get("candidate_power", 0.0)),
			"comparison_mode": str(equipment_evaluation.get("comparison_mode", "power")),
			"candidate_belt_healing": float(equipment_evaluation.get("candidate_belt_healing", 0.0)),
			"candidate_belt_health": float(equipment_evaluation.get("candidate_belt_health", 0.0)),
		}
		if best_result.is_empty() or purchase_candidate_is_better(candidate_result, best_result):
			best_result = candidate_result

	return best_result

func purchase_candidate_is_better(candidate: Dictionary, current_best: Dictionary) -> bool:
	var candidate_is_belt: bool = str(candidate.get("comparison_mode", "")) == "belt_utility"
	var best_is_belt: bool = str(current_best.get("comparison_mode", "")) == "belt_utility"
	if candidate_is_belt and best_is_belt:
		var candidate_healing: float = float(candidate.get("candidate_belt_healing", 0.0))
		var best_healing: float = float(current_best.get("candidate_belt_healing", 0.0))
		if candidate_healing > best_healing + POWER_EPSILON:
			return true
		if not is_equal_approx(candidate_healing, best_healing):
			return false
		var candidate_health: float = float(candidate.get("candidate_belt_health", 0.0))
		var best_health: float = float(current_best.get("candidate_belt_health", 0.0))
		if candidate_health > best_health + POWER_EPSILON:
			return true
		if not is_equal_approx(candidate_health, best_health):
			return false
		return int(candidate.get("price", 0)) < int(current_best.get("price", 0))

	var candidate_power_gain: float = float(candidate.get("power_gain", 0.0))
	var best_power_gain: float = float(current_best.get("power_gain", 0.0))
	if candidate_power_gain > best_power_gain + POWER_EPSILON:
		return true
	if candidate_power_gain < best_power_gain - POWER_EPSILON:
		return false
	if candidate_is_belt != best_is_belt:
		return not candidate_is_belt
	return false
