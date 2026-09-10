extends SceneTree

const SimulationSnapshot = preload("res://scripts/core/simulation_snapshot.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(24680)
	advance_until_combat(simulation)
	assert(simulation.active_combat_session != null, "Snapshot fixture must reach an active combat session.")
	assert(simulation.active_combat_session != null, "Combat must remain active at the snapshot point.")

	var captured: Dictionary = SimulationSnapshot.capture(simulation)
	assert(str(captured.get("error", "")).is_empty(), "Capture must not return an error: %s" % str(captured.get("error", "")))
	assert(int(captured.get("version", 0)) == SimulationSnapshot.VERSION, "Snapshot must carry its explicit schema version.")
	var restored_result: Dictionary = SimulationSnapshot.restore(captured)
	if not str(restored_result.get("error", "")).is_empty():
		quit()
		return
	assert(str(restored_result.get("error", "")).is_empty(), "Restore must not return an error: %s" % str(restored_result.get("error", "")))
	var restored = restored_result.get("simulation")
	assert(restored != null and restored != simulation, "Restore must return a detached Simulation.")
	assert(restored.active_combat_session != null, "Active combat must survive restore.")
	assert(restored.world_state.hero_position_changed.is_connected(restored.on_hero_position_changed), "Restored world callback must be connected.")
	assert(restored.active_combat_session.random_number_generator.state == simulation.active_combat_session.random_number_generator.state, "Combat RNG state must survive restore.")

	simulation.advance_time(60.0)
	restored.advance_time(60.0)
	assert(restored.world_clock.world_tick == simulation.world_clock.world_tick, "Continuation must consume identical world ticks.")
	assert(restored.combat_results_by_mob == simulation.combat_results_by_mob, "Combat continuation must preserve identical results.")
	assert(restored.hero_state.current_hp == simulation.hero_state.current_hp, "Continuation must preserve hero HP.")

	var malformed: Dictionary = captured.duplicate(true)
	malformed["version"] = 999
	var invalid_result: Dictionary = SimulationSnapshot.restore(malformed)
	assert(invalid_result.get("simulation") == null and not str(invalid_result.get("error", "")).is_empty(), "Unknown snapshot versions must fail safely.")
	var unsafe_resource: Dictionary = captured.duplicate(true)
	unsafe_resource["nodes"][0]["properties"]["active_combat_mob_definition"] = {"resource": "res://data/../scripts/core/simulation.gd"}
	invalid_result = SimulationSnapshot.restore(unsafe_resource)
	assert(invalid_result.get("simulation") == null and not str(invalid_result.get("error", "")).is_empty(), "Unsafe resource paths must fail without loading scripts.")
	print("PASS: Simulation snapshot preserves active combat and deterministic continuation.")
	quit()

func advance_until_combat(simulation) -> void:
	var guard := 0
	while simulation.active_combat_session == null and guard < 20:
		simulation.advance_time(10.0)
		guard += 1
