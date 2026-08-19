extends SceneTree

func _init() -> void:
	var combat_simulator_script: Script = load("res://scripts/combat/combat_simulator.gd")
	var combat_stats_script: Script = load("res://scripts/model/runtime/combat_stats.gd")
	assert(combat_simulator_script != null, "CombatSimulator script must exist.")
	assert(combat_stats_script != null, "CombatStats script must exist.")

	var hero_stats: RefCounted = combat_stats_script.new()
	hero_stats.max_hp = 20.0
	hero_stats.attack = 10.0
	hero_stats.attack_speed = 1.0
	hero_stats.crit_chance = 1.0
	hero_stats.crit_damage = 2.0

	var mob_stats: RefCounted = combat_stats_script.new()
	mob_stats.max_hp = 15.0
	mob_stats.attack = 0.0
	mob_stats.attack_speed = 1.0
	mob_stats.crit_chance = 0.0

	var combat_simulator: RefCounted = combat_simulator_script.new()
	var result = combat_simulator.simulate(hero_stats, mob_stats)

	assert(result.hero_won, "The hero must win after a guaranteed critical hit.")
	assert(result.actions.size() == 1, "The fight must stop after the lethal opening hit.")
	assert(result.actions[0].is_critical, "A 100% crit chance must produce a critical hit.")
	assert(is_equal_approx(result.actions[0].damage, 20.0), "Critical damage must equal Attack multiplied by CritDamage.")

	print("PASS: CombatSimulator applies critical-hit damage without rounding.")
	quit()
