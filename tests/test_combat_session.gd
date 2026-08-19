extends SceneTree

func _init() -> void:
	var combat_simulator_script: Script = load("res://scripts/combat/combat_simulator.gd")
	var combat_stats_script: Script = load("res://scripts/model/runtime/combat_stats.gd")
	assert(combat_simulator_script != null, "CombatSimulator script must exist.")
	assert(combat_stats_script != null, "CombatStats script must exist.")

	var hero_stats: RefCounted = combat_stats_script.new()
	hero_stats.max_hp = 30.0
	hero_stats.attack = 10.0
	hero_stats.attack_speed = 1.0
	hero_stats.crit_chance = 0.0

	var mob_stats: RefCounted = combat_stats_script.new()
	mob_stats.max_hp = 30.0
	mob_stats.attack = 10.0
	mob_stats.attack_speed = 1.0
	mob_stats.crit_chance = 0.0

	var combat_simulator: RefCounted = combat_simulator_script.new()
	var session = combat_simulator.create_session(hero_stats, mob_stats)

	assert(session.advance(1.49).is_empty(), "No strike may resolve before the hero's 1.5-second opening attack.")
	var actions = session.advance(0.01)
	assert(actions.size() == 1, "The hero opening attack must resolve when its timer reaches 1.5 seconds.")
	assert(actions[0].attacker_id == "hero", "The hero must land the first opening attack.")
	assert(is_equal_approx(actions[0].time_seconds, 1.5), "The first action must retain its exact internal timestamp.")
	assert(not session.is_finished, "The session must remain active until one combatant reaches zero HP.")

	actions = session.advance(0.5)
	assert(actions.size() == 1, "The mob must attack separately when its own timer reaches 2 seconds.")
	assert(actions[0].attacker_id == "mob", "The mob strike must not be resolved early with the hero strike.")
	assert(is_equal_approx(actions[0].time_seconds, 2.0), "The mob action must retain its own internal timestamp.")

	print("PASS: CombatSession resolves attacks only when their internal timers elapse.")
	quit()
