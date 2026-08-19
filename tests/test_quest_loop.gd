extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new()
	simulation.hero_state.hero_name = "Алексей"
	simulation.advance_time(30.0)
	assert(simulation.world_clock.world_tick == 3, "Arrival must complete on the third world tick.")
	assert(simulation.hero_state.loop_state == HeroState.DOING_QUEST, "Arrival must leave the hero ready to start combat.")

	simulation.advance_time(1.0)
	assert(simulation.active_combat_session != null, "Combat must begin as a live session after arrival.")
	assert(simulation.world_clock.world_tick == 3, "World ticks must freeze while internal combat is running.")

	simulation.advance_time(0.5)
	assert(simulation.world_clock.world_tick == 3, "The world clock must still be frozen when the first combat action resolves.")
	assert(count_entries_containing(simulation.debug_log.entries, "нанёс") >= 1, "Each resolved combat action must be written to the debug log immediately.")

	simulation.set_time_scale(100.0)
	simulation.advance_time(0.2)
	assert(simulation.active_combat_session == null, "The first combat session must finish at x100 speed.")
	assert(simulation.world_clock.world_tick == 4, "Exactly one world tick must be counted after a finished fight.")
	assert(simulation.hero_state.experience == 50, "The hero must gain the goblin's XP immediately after victory.")
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_AFTER_FIGHT, "Recovery must begin only after the completed combat tick.")

	print("PASS: Live combat freezes world ticks, logs attacks, and awards XP after victory.")
	quit()

func count_entries_containing(entries: Array[String], text: String) -> int:
	var count := 0
	for entry in entries:
		if entry.contains(text):
			count += 1
	return count
