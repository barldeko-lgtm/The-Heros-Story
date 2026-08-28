class_name PowerCalculator
extends RefCounted

const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")
const REFERENCE_TARGET_DODGE: float = 50.0
const REFERENCE_ATTACKER_ACCURACY: float = 100.0
const PHYSICAL_DAMAGE_WEIGHT: float = 0.70
const FIRE_DAMAGE_WEIGHT: float = 0.10
const COLD_DAMAGE_WEIGHT: float = 0.10
const LIGHTNING_DAMAGE_WEIGHT: float = 0.10

func calculate(combat_stats) -> float:
	var crit_chance := clampf(combat_stats.crit_chance, 0.0, 1.0)
	var crit_damage := maxf(1.0, combat_stats.crit_damage)
	var crit_modifier := 1.0 + crit_chance * (crit_damage - 1.0)
	var raw_dps := maxf(0.0, combat_stats.attack) * (maxf(0.0, combat_stats.attack_speed) / 2.0) * crit_modifier
	var accuracy := maxf(0.0, combat_stats.accuracy)
	var accuracy_factor := 1.5 * (accuracy + 100.0) / (accuracy + 150.0)
	var effective_dps := raw_dps * accuracy_factor

	var physical_taken := DamageResolverScript.calculate_physical_taken(combat_stats.armor)
	var fire_taken := DamageResolverScript.calculate_elemental_taken(combat_stats.fire_resistance)
	var cold_taken := DamageResolverScript.calculate_elemental_taken(combat_stats.cold_resistance)
	var lightning_taken := DamageResolverScript.calculate_elemental_taken(combat_stats.lightning_resistance)
	var average_damage_taken := (
		PHYSICAL_DAMAGE_WEIGHT * physical_taken
		+ FIRE_DAMAGE_WEIGHT * fire_taken
		+ COLD_DAMAGE_WEIGHT * cold_taken
		+ LIGHTNING_DAMAGE_WEIGHT * lightning_taken
	)
	var reference_dodge_chance := DamageResolverScript.calculate_dodge_chance(REFERENCE_ATTACKER_ACCURACY, combat_stats.dodge)
	var block_multiplier := DamageResolverScript.calculate_block_multiplier(combat_stats.block)
	var defensive_denominator := average_damage_taken * (1.0 - reference_dodge_chance) * block_multiplier
	if defensive_denominator <= 0.0 or effective_dps <= 0.0:
		return 0.0
	var effective_hp := maxf(0.0, combat_stats.max_hp) / defensive_denominator
	return sqrt(effective_hp * effective_dps)
