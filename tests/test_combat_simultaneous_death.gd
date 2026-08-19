extends SceneTree

func _init() -> void:
	var combat_simulator_script: Script = load("res://scripts/combat/combat_simulator.gd")
	var combat_stats_script: Script = load("res://scripts/model/runtime/combat_stats.gd")
	assert(combat_simulator_script != null, "CombatSimulator script must exist.")
	assert(combat_stats_script != null, "CombatStats script must exist.")

	var hero_stats: RefCounted = combat_stats_script.new()
	hero_stats.max_hp = 10.0
	hero_stats.attack = 10.0
	hero_stats.attack_speed = 1.0
	hero_stats.crit_chance = 0.0

	var mob_stats: RefCounted = combat_stats_script.new()
	mob_stats.max_hp = 20.0
	mob_stats.attack = 10.0
	mob_stats.attack_speed = 2.0 / 3.5
	mob_stats.crit_chance = 0.0

	var combat_simulator: RefCounted = combat_simulator_script.new()
	var result = combat_simulator.simulate(hero_stats, mob_stats)

	assert(not result.hero_won, "A simultaneous death must count as hero defeat.")
	assert(is_zero_approx(result.hero_remaining_hp), "The mob's simultaneous hit must reduce hero HP to zero.")
	assert(is_zero_approx(result.mob_remaining_hp), "The hero's simultaneous hit must reduce mob HP to zero.")
	assert(result.actions.size() == 3, "The opening hit and both simultaneous attacks must be recorded.")
	assert(is_equal_approx(result.actions[1].time_seconds, 3.5), "The hero's finishing hit must occur at the shared timestamp.")
	assert(is_equal_approx(result.actions[2].time_seconds, 3.5), "The mob's simultaneous hit must occur at the shared timestamp.")

	print("PASS: Simultaneous death is recorded as hero defeat.")
	quit()
