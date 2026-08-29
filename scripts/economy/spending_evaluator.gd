class_name SpendingEvaluator
extends RefCounted

const EquipmentEvaluatorScript = preload("res://scripts/hero/equipment_evaluator.gd")
const ItemPriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")

const SHOP_ITEMPOWER_THRESHOLD_MULTIPLIER: float = 1.20
const POWER_EPSILON: float = 0.000001

var equipment_evaluator = EquipmentEvaluatorScript.new()
var item_price_calculator = ItemPriceCalculatorScript.new()

func select_best_equipment_purchase(hero_state, listings: Array) -> Dictionary:
	var best_result: Dictionary = {}
	if hero_state == null:
		return best_result

	for listing_index in listings.size():
		var listing = listings[listing_index]
		if listing == null:
			continue
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.definition == null:
			continue

		var price: int = item_price_calculator.get_reference_shop_value_for_item(item_instance)
		if price < 0 or price > hero_state.gold:
			continue

		var current_item = hero_state.equipment.get_item(item_instance.definition.equipment_slot)
		var current_item_power: float = 0.0 if current_item == null else current_item.get_item_power()
		var candidate_item_power: float = item_instance.get_item_power()
		if current_item != null and candidate_item_power + POWER_EPSILON < current_item_power * SHOP_ITEMPOWER_THRESHOLD_MULTIPLIER:
			continue

		var equipment_evaluation: Dictionary = equipment_evaluator.evaluate(hero_state, item_instance)
		if not bool(equipment_evaluation.get("should_equip", false)):
			continue

		var power_gain: float = float(equipment_evaluation.get("candidate_power", 0.0)) - float(equipment_evaluation.get("current_power", 0.0))
		if power_gain <= POWER_EPSILON:
			continue

		if best_result.is_empty() or power_gain > float(best_result.get("power_gain", 0.0)) + POWER_EPSILON:
			best_result = {
				"listing_index": listing_index,
				"listing": listing,
				"item_instance": item_instance,
				"price": price,
				"current_item_power": current_item_power,
				"candidate_item_power": candidate_item_power,
				"power_gain": power_gain,
				"current_power": float(equipment_evaluation.get("current_power", 0.0)),
				"candidate_power": float(equipment_evaluation.get("candidate_power", 0.0)),
			}

	return best_result
