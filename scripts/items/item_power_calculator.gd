class_name ItemPowerCalculator
extends RefCounted

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")

const REFERENCE_MAX_HP: float = 1000.0
const REFERENCE_ARMOR: float = 100.0
const REFERENCE_DODGE: float = 50.0
const REFERENCE_ACCURACY: float = 100.0
const REFERENCE_ATTACK: float = 100.0
const REFERENCE_ATTACK_SPEED: float = 1.0
const REFERENCE_CRIT_CHANCE: float = 0.25
const REFERENCE_CRIT_DAMAGE: float = 2.0
const REFERENCE_FIRE_RESISTANCE: float = 100.0
const REFERENCE_COLD_RESISTANCE: float = 100.0
const REFERENCE_LIGHTNING_RESISTANCE: float = 100.0
const REFERENCE_BLOCK: float = 0.0

static func get_reference_power() -> float:
	return PowerCalculatorScript.new().calculate(create_reference_stats())

static func calculate(item_source) -> float:
	if item_source == null:
		return 0.0
	var item_stats = create_reference_stats()
	if item_source.has_method("get_stat_bonus"):
		apply_generated_item_stats(item_stats, item_source)
	else:
		apply_legacy_definition_stats(item_stats, item_source)
	var total_power: float = PowerCalculatorScript.new().calculate(item_stats)
	return maxf(0.0, total_power - get_reference_power())

static func apply_generated_item_stats(item_stats, item_instance) -> void:
	item_stats.max_hp += item_instance.get_stat_bonus("max_hp")
	item_stats.armor += item_instance.get_stat_bonus("armor")
	item_stats.dodge += item_instance.get_stat_bonus("dodge")
	item_stats.accuracy += item_instance.get_stat_bonus("accuracy")
	item_stats.attack += item_instance.get_stat_bonus("attack")
	item_stats.attack_speed += item_instance.get_stat_bonus("attack_speed")
	item_stats.crit_chance += item_instance.get_stat_bonus("crit_chance")
	item_stats.crit_damage += item_instance.get_stat_bonus("crit_damage")
	item_stats.fire_resistance += item_instance.get_stat_bonus("fire_resistance")
	item_stats.cold_resistance += item_instance.get_stat_bonus("cold_resistance")
	item_stats.lightning_resistance += item_instance.get_stat_bonus("lightning_resistance")
	item_stats.block += item_instance.get_stat_bonus("block")

static func apply_legacy_definition_stats(item_stats, item_definition: Resource) -> void:
	item_stats.max_hp += item_definition.max_hp_bonus
	item_stats.armor += item_definition.armor_bonus
	item_stats.attack += item_definition.strength_bonus * StatResolverScript.PHYSICAL_DAMAGE_PER_STRENGTH + item_definition.attack_bonus
	item_stats.crit_chance += item_definition.crit_chance_bonus
	item_stats.crit_damage += item_definition.strength_bonus * StatResolverScript.CRIT_DAMAGE_PER_STRENGTH + item_definition.crit_damage_bonus

static func create_reference_stats():
	var stats = CombatStatsScript.new()
	stats.max_hp = REFERENCE_MAX_HP
	stats.attack = REFERENCE_ATTACK
	stats.attack_speed = REFERENCE_ATTACK_SPEED
	stats.accuracy = REFERENCE_ACCURACY
	stats.dodge = REFERENCE_DODGE
	stats.armor = REFERENCE_ARMOR
	stats.fire_resistance = REFERENCE_FIRE_RESISTANCE
	stats.cold_resistance = REFERENCE_COLD_RESISTANCE
	stats.lightning_resistance = REFERENCE_LIGHTNING_RESISTANCE
	stats.block = REFERENCE_BLOCK
	stats.crit_chance = REFERENCE_CRIT_CHANCE
	stats.crit_damage = REFERENCE_CRIT_DAMAGE
	return stats
