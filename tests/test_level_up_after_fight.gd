extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new(12345)
	simulation.hero_state.hero_name = "Алексей"
	simulation.hero_state.experience = 950
	simulation.advance_time(30.0)
	simulation.set_time_scale(100.0)
	simulation.advance_time(0.2)

	assert(simulation.active_combat_session == null, "The first combat must finish at x100 speed.")
	assert(simulation.hero_state.level == 2, "The first goblin's 50 XP must level a hero from 950 / 1000 to level 2.")
	assert(simulation.hero_state.experience == 0, "XP must roll over after the level-up.")
	assert(simulation.hero_state.strength == 6, "Level-up must grant +4 Strength.")
	assert(simulation.hero_state.agility == 3, "Level-up must grant +1 Agility.")
	assert(is_equal_approx(simulation.combat_stats.max_hp, 150.0), "Resolved MaxHP must refresh immediately after level-up.")
	assert(is_equal_approx(simulation.combat_stats.attack, 11.0), "Resolved Attack must refresh immediately after level-up.")
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_AFTER_FIGHT, "Level-up must not skip normal post-fight recovery.")
	assert(simulation.debug_log.get_text().contains("повысил уровень: 1 → 2"), "The debug log must show the level-up.")

	print("PASS: Combat XP is applied by HeroProgression and refreshed stats are ready for the next fight.")
	quit()
