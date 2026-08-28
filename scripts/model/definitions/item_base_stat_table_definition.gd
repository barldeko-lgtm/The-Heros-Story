class_name ItemBaseStatTableDefinition
extends Resource

@export var item_levels: Array[int] = []
@export var armor_values: Array[float] = []
@export var sword_damage_values: Array[float] = []
@export var sword_attack_speed_bonus: float = 0.10
@export var shield_block_values: Array[float] = []
@export var belt_health_values: Array[float] = []
@export var jewelry_resistance_values: Array[float] = []

func get_armor(item_level: int) -> float:
	return get_tier_value(item_level, armor_values)

func get_sword_damage(item_level: int) -> float:
	return get_tier_value(item_level, sword_damage_values)

func get_sword_attack_speed_bonus(item_level: int) -> float:
	if item_levels.find(item_level) < 0:
		return -1.0
	return sword_attack_speed_bonus

func get_shield_block(item_level: int) -> float:
	return get_tier_value(item_level, shield_block_values)

func get_belt_health(item_level: int) -> float:
	return get_tier_value(item_level, belt_health_values)

func get_jewelry_resistance(item_level: int) -> float:
	return get_tier_value(item_level, jewelry_resistance_values)

func get_tier_value(item_level: int, values: Array[float]) -> float:
	var tier_index: int = item_levels.find(item_level)
	if tier_index < 0 or tier_index >= values.size():
		return -1.0
	return values[tier_index]
