extends SceneTree

func _init() -> void:
	var combat_simulator_script: Script = load("res://scripts/combat/combat_simulator.gd")
	assert(combat_simulator_script != null, "CombatSimulator script must exist.")

	var combat_stats_script: Script = load("res://scripts/model/runtime/combat_stats.gd")
	assert(combat_stats_script != null, "CombatStats script must exist.")

	var hero_stats: RefCounted = combat_stats_script.new()
	hero_stats.max_hp = 20.0
	hero_stats.attack = 15.0
	hero_stats.attack_speed = 1.0
	hero_stats.crit_chance = 0.0
	hero_stats.crit_damage = 1.5

	var mob_stats: RefCounted = combat_stats_script.new()
	mob_stats.max_hp = 25.0
	mob_stats.attack = 10.0
	mob_stats.attack_speed = 1.0
	mob_stats.crit_chance = 0.0
	mob_stats.crit_damage = 1.5

	var combat_simulator: RefCounted = combat_simulator_script.new()
	var result = combat_simulator.simulate(hero_stats, mob_stats)

	assert(result.hero_won, "The hero must win after landing the opening hit 0.5 seconds before an equally fast mob.")
	assert(is_equal_approx(result.hero_remaining_hp, 10.0), "The mob must land exactly one hit before dying.")
	assert(is_equal_approx(result.mob_remaining_hp, -5.0), "Combat damage must retain exact HP values without display rounding.")
	assert(is_equal_approx(result.duration_seconds, 3.5), "The combat duration must include the hero's 0.5-second opening advantage.")
	assert(result.actions.size() == 3, "The combat result must record every resolved attack.")
	assert(is_equal_approx(result.actions[0].time_seconds, 1.5), "The hero's first attack must occur 0.5 seconds before the normal interval.")
	assert(result.actions[0].attacker_id == "hero", "The hero must make the opening attack.")

	print("PASS: CombatSimulator gives the hero the approved 0.5-second opening advantage.")
	quit()
