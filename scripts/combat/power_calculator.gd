class_name PowerCalculator
extends RefCounted

const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")
const REFERENCE_TARGET_DODGE: float = 50.0
const REFERENCE_ATTACKER_ACCURACY: float = 100.0
const PHYSICAL_DAMAGE_WEIGHT: float = 0.70
const FIRE_DAMAGE_WEIGHT: float = 0.10
const COLD_DAMAGE_WEIGHT: float = 0.10
const LIGHTNING_DAMAGE_WEIGHT: float = 0.10
const ELEMENTAL_OFFENSE_MULTIPLIER: float = 1.20
const POWER_STRIKE_LEARNED_POWER_BONUS: float = 0.04
const POWER_STRIKE_RANK_POWER_BONUS: float = 0.0075
const BATTLE_GUARD_LEARNED_POWER_BONUS: float = 0.045
const BATTLE_GUARD_RANK_POWER_BONUS: float = 0.004
const WISDOM_POWER_BONUS_PER_POINT: float = 0.002
const BASE_WISDOM: int = 5

func calculate(combat_stats, damage_type: String = DamageResolverScript.DAMAGE_TYPE_PHYSICAL) -> float:
	var crit_chance := clampf(combat_stats.crit_chance, 0.0, 1.0)
	var crit_damage := maxf(1.0, combat_stats.crit_damage)
	var crit_modifier := 1.0 + crit_chance * (crit_damage - 1.0)
	var raw_dps := maxf(0.0, combat_stats.attack) * (maxf(0.0, combat_stats.attack_speed) / 2.0) * crit_modifier
	var accuracy := maxf(0.0, combat_stats.accuracy)
	var accuracy_factor := 1.5 * (accuracy + 100.0) / (accuracy + 150.0)
	var effective_dps := raw_dps * accuracy_factor
	if damage_type != DamageResolverScript.DAMAGE_TYPE_PHYSICAL:
		effective_dps *= ELEMENTAL_OFFENSE_MULTIPLIER

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

func calculate_hero(combat_stats, hero_state, damage_type: String = DamageResolverScript.DAMAGE_TYPE_PHYSICAL) -> float:
	return calculate(combat_stats, damage_type) * get_hero_ability_power_multiplier(hero_state)

func get_hero_ability_power_multiplier(hero_state) -> float:
	if hero_state == null:
		return 1.0
	var power_bonus: float = 0.0
	var power_strike_skill_level: int = maxi(0, int(hero_state.power_strike_skill_level))
	var battle_guard_skill_level: int = maxi(0, int(hero_state.battle_guard_skill_level))
	if power_strike_skill_level > 0:
		power_bonus += POWER_STRIKE_LEARNED_POWER_BONUS
		power_bonus += float(power_strike_skill_level - 1) * POWER_STRIKE_RANK_POWER_BONUS
	if battle_guard_skill_level > 0:
		power_bonus += BATTLE_GUARD_LEARNED_POWER_BONUS
		power_bonus += float(battle_guard_skill_level - 1) * BATTLE_GUARD_RANK_POWER_BONUS
	if power_strike_skill_level > 0 and battle_guard_skill_level > 0:
		power_bonus += float(maxi(0, int(hero_state.wisdom) - BASE_WISDOM)) * WISDOM_POWER_BONUS_PER_POINT
	return 1.0 + power_bonus
