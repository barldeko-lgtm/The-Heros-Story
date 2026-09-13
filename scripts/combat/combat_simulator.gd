class_name CombatSimulator
extends RefCounted

const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")

func create_session(hero_stats: CombatStats, mob_stats: CombatStats, random_number_generator: RandomNumberGenerator = null, hero_damage_multiplier: float = 1.0, power_strike_skill_level: int = 0, hero_wisdom: int = 5, battle_guard_skill_level: int = 0, shield_bash_skill_level: int = 0, crippling_blows_skill_level: int = 0, hero_has_shield: bool = false):
	return CombatSessionScript.new(hero_stats, mob_stats, random_number_generator, hero_damage_multiplier, power_strike_skill_level, hero_wisdom, battle_guard_skill_level, shield_bash_skill_level, crippling_blows_skill_level, hero_has_shield)

func simulate(hero_stats: CombatStats, mob_stats: CombatStats, random_number_generator: RandomNumberGenerator = null, hero_damage_multiplier: float = 1.0, power_strike_skill_level: int = 0, hero_wisdom: int = 5, battle_guard_skill_level: int = 0, mob_damage_type: String = "physical", shield_bash_skill_level: int = 0, crippling_blows_skill_level: int = 0, hero_has_shield: bool = false):
	var session = create_session(hero_stats, mob_stats, random_number_generator, hero_damage_multiplier, power_strike_skill_level, hero_wisdom, battle_guard_skill_level, shield_bash_skill_level, crippling_blows_skill_level, hero_has_shield)
	session.advance(1000000.0, mob_damage_type)
	return session.get_result()
