class_name ItemPriceCalculator
extends RefCounted

const DefaultPriceTable = preload("res://data/items/balance/item_price_table.tres")

var price_table: Resource

func _init(initial_price_table: Resource = DefaultPriceTable) -> void:
	price_table = initial_price_table

func get_reference_shop_value(item_level: int, rarity: int) -> int:
	return price_table.get_reference_shop_value(item_level, rarity)

func get_sell_price_for_level_and_rarity(item_level: int, rarity: int) -> int:
	return price_table.get_sell_price(item_level, rarity)

func get_reference_shop_value_for_item(item_instance) -> int:
	if item_instance == null:
		return -1
	if item_instance.definition != null and item_instance.definition.reference_shop_value_override >= 0:
		return item_instance.definition.reference_shop_value_override
	return get_reference_shop_value(item_instance.item_level, item_instance.rarity)

func get_sell_price_for_item(item_instance) -> int:
	if item_instance == null:
		return -1
	var reference_value: int = get_reference_shop_value_for_item(item_instance)
	if reference_value < 0:
		return -1
	return roundi(float(reference_value) * price_table.sell_fraction)
