class_name CombatSimulator
extends RefCounted

const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")

func create_session(hero_stats: CombatStats, mob_stats: CombatStats, random_number_generator: RandomNumberGenerator = null, hero_damage_multiplier: float = 1.0, hero_attack_bonus: float = 0.0):
	return CombatSessionScript.new(hero_stats, mob_stats, random_number_generator, hero_damage_multiplier, hero_attack_bonus)

func simulate(hero_stats: CombatStats, mob_stats: CombatStats, random_number_generator: RandomNumberGenerator = null, hero_damage_multiplier: float = 1.0, hero_attack_bonus: float = 0.0):
	var session = create_session(hero_stats, mob_stats, random_number_generator, hero_damage_multiplier, hero_attack_bonus)
	session.advance(1000000.0)
	return session.get_result()
