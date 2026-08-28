class_name ItemPriceTableDefinition
extends Resource

@export var item_levels: Array[int] = []
@export var white_reference_values: Array[int] = []
@export var uncommon_multiplier: float = 3.0
@export var rare_multiplier: float = 9.0
@export var sell_fraction: float = 0.10

func get_reference_shop_value(item_level: int, rarity: int) -> int:
	var tier_index: int = item_levels.find(item_level)
	if tier_index < 0 or tier_index >= white_reference_values.size():
		return -1
	var white_value: float = float(white_reference_values[tier_index])
	match rarity:
		0: return roundi(white_value)
		1: return roundi(white_value * uncommon_multiplier)
		2: return roundi(white_value * rare_multiplier)
	return -1

func get_sell_price(item_level: int, rarity: int) -> int:
	var reference_value: int = get_reference_shop_value(item_level, rarity)
	if reference_value < 0:
		return -1
	return roundi(float(reference_value) * sell_fraction)
