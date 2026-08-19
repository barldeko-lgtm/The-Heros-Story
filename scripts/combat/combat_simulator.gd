class_name CombatSimulator
extends RefCounted

const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")

func create_session(hero_stats: CombatStats, mob_stats: CombatStats, random_number_generator: RandomNumberGenerator = null):
	return CombatSessionScript.new(hero_stats, mob_stats, random_number_generator)

func simulate(hero_stats: CombatStats, mob_stats: CombatStats, random_number_generator: RandomNumberGenerator = null):
	var session = create_session(hero_stats, mob_stats, random_number_generator)
	session.advance(1000000.0)
	return session.get_result()
