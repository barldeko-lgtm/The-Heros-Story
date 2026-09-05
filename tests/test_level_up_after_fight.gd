extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new(12345)
	simulation.hero_state.hero_name = "Алексей"
	simulation.hero_state.experience = 950
	simulation.advance_time(30.0)
	simulation.set_time_scale(100.0)
	for _step in 20:
		simulation.advance_time(0.1)
		if simulation.hero_state.level == 2:
			break

	assert(simulation.active_combat_session == null, "The first combat must finish at x100 speed.")
	assert(simulation.hero_state.level == 2, "The first goblin's 50 XP must level a hero from 950 / 1000 to level 2.")
	assert(simulation.hero_state.experience == 0, "XP must roll over after the level-up.")
	assert(simulation.hero_state.strength == 6, "Level-up must automatically grant exactly +1 Warrior Strength.")
	assert(simulation.hero_state.dexterity == 5 and simulation.hero_state.constitution == 5, "The four free primary points must not be assigned automatically.")
	assert(simulation.hero_state.pending_primary_attribute_points == 4, "Combat level-up must bank four player-distributed points.")
	assert(is_equal_approx(simulation.combat_stats.max_hp, 200.0), "Pending Constitution must provide no MaxHP before allocation.")
	assert(is_equal_approx(simulation.combat_stats.attack, 17.0), "Resolved physical Damage must refresh with only the fixed +1 Strength.")
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_AFTER_FIGHT, "Level-up must not skip normal post-fight recovery.")
	assert(simulation.debug_log.get_text().contains("повысил уровень: 1 → 2"), "The debug log must show the level-up.")
	assert(simulation.allocate_primary_attribute("constitution"), "A player must be able to spend one pending point through Simulation outside combat.")
	assert(simulation.hero_state.constitution == 6 and simulation.hero_state.pending_primary_attribute_points == 3, "Simulation allocation must consume exactly one pending point into the selected attribute.")
	assert(is_equal_approx(simulation.combat_stats.max_hp, 220.0), "Allocating Constitution through Simulation must immediately refresh resolved MaxHP.")

	print("PASS: Combat XP is applied by HeroProgression and refreshed stats are ready for the next fight.")
	quit()
