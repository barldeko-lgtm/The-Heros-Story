extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new()
	simulation.hero_state.hero_name = "Алексей"
	simulation.advance_time(30.0)
	simulation.set_time_scale(100.0)

	var guard := 0
	while simulation.hero_state.gold == 0 and guard < 1000:
		simulation.advance_time(0.01)
		guard += 1

	assert(guard < 1000, "The five-goblin quest must complete under the current safe test balance.")
	assert(simulation.world_clock.world_tick == 16, "Five resolved fights, recovery, return travel, and turn-in must consume sixteen world ticks.")
	assert(simulation.hero_state.gold == 20, "Gold must still be granted only at quest turn-in.")
	assert(simulation.hero_state.experience == 250, "Five defeated goblins must award five times 50 XP.")
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "The hero must return to quest selection after the completed quest.")
	assert(is_equal_approx(simulation.hero_state.current_hp, simulation.combat_stats.max_hp), "The hero must recover fully after the final fight before returning.")
	assert(count_entries_containing(simulation.debug_log.entries, "получил 50 XP") == 5, "Every defeated quest mob must award its own XP.")

	print("PASS: Five live fights award 250 XP and complete the full quest loop.")
	quit()

func count_entries_containing(entries: Array[String], text: String) -> int:
	var count := 0
	for entry in entries:
		if entry.contains(text):
			count += 1
	return count
