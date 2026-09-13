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
	var legacy_v1: Dictionary = captured.duplicate(true)
	legacy_v1["version"] = SimulationSnapshot.LEGACY_VERSION_1
	var legacy_hero_id: int = legacy_v1.nodes[legacy_v1.root.ref].properties.hero_state.ref
	for property_name in [
		"specialization_decision_active",
		"specialization_decision_start_tick",
		"specialization_decision_ticks_remaining",
		"specialization_courage_trait_snapshot",
		"specialization_guidance_id",
		"first_specialization_id",
		"specialization_final_protector_base",
		"specialization_final_slayer_base",
		"specialization_final_protector_score",
		"specialization_final_slayer_score",
	]:
		legacy_v1.nodes[legacy_hero_id].properties.erase(property_name)
	var legacy_result: Dictionary = SimulationSnapshot.restore(legacy_v1)
	assert(str(legacy_result.get("error", "")).is_empty() and legacy_result.get("simulation") != null, "Legacy v1 snapshots must migrate to default first-specialization state.")

	var legacy_v2: Dictionary = captured.duplicate(true)
	legacy_v2["version"] = SimulationSnapshot.LEGACY_VERSION_2
	var legacy_v2_hero_id: int = legacy_v2.nodes[legacy_v2.root.ref].properties.hero_state.ref
	legacy_v2.nodes[legacy_v2_hero_id].properties.erase("shield_bash_skill_level")
	legacy_v2.nodes[legacy_v2_hero_id].properties.erase("crippling_blows_skill_level")
	var legacy_v2_combat_id: int = legacy_v2.nodes[legacy_v2.root.ref].properties.active_combat_session.ref
	for property_name in [
		"shield_bash_skill_level",
		"shield_bash_ready_time",
		"crippling_blows_skill_level",
		"crippling_blows_ready_time",
		"hero_has_shield",
		"crippling_slow_active_until",
		"crippling_slow_reduction",
	]:
		legacy_v2.nodes[legacy_v2_combat_id].properties.erase(property_name)
	var legacy_v2_result: Dictionary = SimulationSnapshot.restore(legacy_v2)
	assert(str(legacy_v2_result.get("error", "")).is_empty() and legacy_v2_result.get("simulation") != null, "Legacy v2 snapshots must migrate to default specialization-skill combat state.")

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
