class_name ItemPowerCalculator
extends RefCounted

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")

const REFERENCE_MAX_HP: float = 1.0
const REFERENCE_ATTACK: float = 1.0
const REFERENCE_ATTACK_SPEED: float = 1.0
const REFERENCE_CRIT_CHANCE: float = 0.10
const REFERENCE_CRIT_DAMAGE: float = 1.50
const REFERENCE_DAMAGE_REDUCTION: float = 0.0

static func get_reference_power() -> float:
	return PowerCalculatorScript.new().calculate(create_reference_stats())

static func calculate(item_definition: Resource) -> float:
	if item_definition == null:
		return 0.0
	var item_stats = create_reference_stats()
	item_stats.max_hp += item_definition.max_hp_bonus + item_definition.strength_bonus * 5.0
	item_stats.attack += item_definition.strength_bonus + item_definition.attack_bonus
	item_stats.crit_chance += item_definition.crit_chance_bonus
	item_stats.crit_damage += item_definition.crit_damage_bonus
	item_stats.damage_reduction = clampf(
		REFERENCE_DAMAGE_REDUCTION + item_definition.armor_bonus * StatResolverScript.DAMAGE_REDUCTION_PER_ARMOR_POINT,
		0.0,
		StatResolverScript.MAX_DAMAGE_REDUCTION
	)
	var total_power: float = PowerCalculatorScript.new().calculate(item_stats)
	return maxf(0.0, total_power - get_reference_power())

static func create_reference_stats():
	var stats = CombatStatsScript.new()
	stats.max_hp = REFERENCE_MAX_HP
	stats.attack = REFERENCE_ATTACK
	stats.attack_speed = REFERENCE_ATTACK_SPEED
	stats.crit_chance = REFERENCE_CRIT_CHANCE
	stats.crit_damage = REFERENCE_CRIT_DAMAGE
	stats.damage_reduction = REFERENCE_DAMAGE_REDUCTION
	return stats
