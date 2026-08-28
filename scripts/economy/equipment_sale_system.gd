class_name EquipmentSaleSystem
extends RefCounted

const ItemPriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")

var item_price_calculator = ItemPriceCalculatorScript.new()

func sell_ordinary_inventory(hero_state) -> Dictionary:
	var result: Dictionary = {
		"sold_items": [],
		"sold_count": 0,
		"gold_gained": 0,
	}
	if hero_state == null or hero_state.inventory == null:
		return result

	for item_instance in hero_state.inventory.get_items():
		var sell_price: int = item_price_calculator.get_sell_price_for_item(item_instance)
		if sell_price < 0:
			continue
		if not hero_state.inventory.remove_item(item_instance):
			continue
		result["sold_items"].append(item_instance)
		result["gold_gained"] += sell_price
	result["sold_count"] = result["sold_items"].size()
	hero_state.gold += result["gold_gained"]
	return result
