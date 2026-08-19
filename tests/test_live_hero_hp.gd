extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new(12345)
	simulation.hero_state.hero_name = "Алексей"

	# Reach the quest location.
	simulation.advance_time(30.0)
	assert(simulation.hero_state.loop_state == HeroState.DOING_QUEST, "Hero must be ready to fight.")

	# Start combat and advance far enough for the goblin to land a hit,
	# while keeping the fight active.
	simulation.advance_time(2.1)

	assert(simulation.active_combat_session != null, "Combat must still be active.")
	assert(
		simulation.active_combat_session.hero_remaining_hp < simulation.combat_stats.max_hp,
		"The goblin must have damaged the hero during the live fight."
	)

	# HeroState is committed only when the fight ends.
	assert(
		is_equal_approx(simulation.hero_state.current_hp, simulation.combat_stats.max_hp),
		"HeroState.current_hp should still contain the pre-fight committed HP during live combat."
	)

	# UI-facing read must expose the live combat HP instead.
	assert(
		is_equal_approx(simulation.get_current_hero_hp(), simulation.active_combat_session.hero_remaining_hp),
		"Simulation must expose live hero HP while combat is active."
	)

	print("PASS: UI-facing hero HP follows the live CombatSession during combat.")
	quit()
