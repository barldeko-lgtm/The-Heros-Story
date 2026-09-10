extends SceneTree

const SimulationSnapshot = preload("res://scripts/core/simulation_snapshot.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")
var failures: int = 0

func _init() -> void:
	test_dungeon_continuation_preserves_active_owner()
	test_temporary_event_continuation_preserves_active_owner()
	test_death_and_city_recovery_continuation_preserve_owner()
	if failures == 0:
		print("PASS: Snapshot continuation is deterministic for live dungeon, temporary event, and death/recovery states.")
	quit(0 if failures == 0 else 1)

func test_dungeon_continuation_preserves_active_owner() -> void:
	var original = SimulationScript.new(97101, null)
	original.hero_state.strength = 20
	original.hero_state.dexterity = 10
	original.hero_state.constitution = 200
	original.refresh_combat_stats()
	original.hero_state.current_hp = original.combat_stats.max_hp
	var dungeon = prepare_dungeon_at_entrance(original)
	original.start_dungeon_combat()
	assert(original.active_combat_session != null and original.active_combat_context == original.COMBAT_CONTEXT_DUNGEON, "Fixture must snapshot a real live dungeon combat.")

	var restored = restore_snapshot(original, "live dungeon")
	assert(restored.dungeon_runner.active_dungeon != null, "Restored DungeonRunner must retain its active dungeon.")
	assert(restored.dungeon_runner.active_dungeon.definition.id == dungeon.definition.id, "Restored active dungeon must be the same authored dungeon.")
	assert(restored.active_combat_context == restored.COMBAT_CONTEXT_DUNGEON, "Restored live combat must retain dungeon ownership.")
	assert(restored.active_combat_session.random_number_generator.state == original.active_combat_session.random_number_generator.state, "Dungeon combat RNG state must survive restore.")
	assert(restored.world_state.hero_position_changed.is_connected(restored.on_hero_position_changed), "Restored dungeon world-position callback must be connected.")
	assert(restored.world_clock.tick_completed.is_connected(restored.on_world_tick_completed), "Restored dungeon tick callback must be connected.")

	original.advance_active_combat(1000000.0)
	restored.advance_active_combat(1000000.0)
	assert_snapshot_equal(original, restored, "after identical live-dungeon combat continuation")
	assert(restored.dungeon_runner.active_dungeon != null, "DungeonRunner must still own the expedition after the first completed fight.")
	assert(restored.hero_state.loop_state == original.hero_state.loop_state, "Dungeon continuation must retain the same phase.")

func test_temporary_event_continuation_preserves_active_owner() -> void:
	var original = create_started_old_clearing(97102)
	original.trait_development.reset_state(original.hero_state)
	original.hero_state.strength = 5
	original.hero_state.dexterity = 5
	original.hero_state.wisdom = 30
	original.advance_event_tick(1)
	original.advance_event_tick(2)
	assert(original.event_runner.active_event != null and original.hero_state.loop_state == HeroState.EVENT_ACTIVE, "Fixture must snapshot a real active temporary event.")

	var restored = restore_snapshot(original, "active temporary event")
	assert(restored.event_runner.active_event != null, "Restored EventRunner must retain its active event.")
	assert(restored.event_runner.active_event.definition.id == original.event_runner.active_event.definition.id, "Restored active event must retain its authored definition.")
	assert(restored.travel_system.has_suspended_travel(), "Restored active event must retain suspended travel.")
	assert(restored.event_runner.travel_system == restored.travel_system, "Restored EventRunner must reference the restored TravelSystem.")
	assert(restored.event_runner.resolution_rng.state == original.event_runner.resolution_rng.state, "Event resolution RNG state must survive restore.")
	assert(restored.world_state.hero_position_changed.is_connected(restored.on_hero_position_changed), "Restored event world-position callback must be connected.")

	for tick in range(3, 9):
		original.advance_event_tick(tick)
		restored.advance_event_tick(tick)
	assert(original.event_runner.active_event == null and restored.event_runner.active_event == null, "Identical event continuation must complete both event instances.")
	assert_snapshot_equal(original, restored, "after identical temporary-event continuation")
	assert(restored.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST and restored.travel_system.is_travelling(), "Completed restored event must resume its interrupted quest travel.")

func test_death_and_city_recovery_continuation_preserve_owner() -> void:
	var original = SimulationScript.new(97103)
	original.quest_runner.quest_definition.mob_definition.attack = 500.0
	original.quest_runner.quest_definition.mob_definition.crit_chance = 0.0
	advance_until_loop_state(original, HeroState.DOING_QUEST, 10)
	original.advance_time(2.0)
	assert(original.hero_state.loop_state == HeroState.DEAD_RESPAWNING and original.get_active_respawn_owner() == original.quest_runner, "Fixture must reach real quest-owned death/respawn state.")

	var restored = restore_snapshot(original, "quest death")
	assert(restored.get_active_respawn_owner() == restored.quest_runner, "Restored QuestRunner must retain death/recovery ownership.")
	assert(restored.quest_runner.respawn_ticks_remaining == original.quest_runner.respawn_ticks_remaining, "Restored death timer must retain its exact remaining ticks.")
	assert(restored.get_respawn_ticks_remaining() == original.get_respawn_ticks_remaining(), "Restored public respawn timer must use the active owner.")
	assert(restored.world_clock.tick_completed.is_connected(restored.on_world_tick_completed), "Restored death/recovery tick callback must be connected.")

	original.advance_time(1000.0)
	restored.advance_time(1000.0)
	assert(original.hero_state.loop_state == HeroState.RECOVERING_IN_CITY and restored.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Identical continuation must resurrect both simulations into city recovery.")
	assert_snapshot_equal(original, restored, "after identical death-to-recovery continuation")
	assert(restored.get_active_respawn_owner() == restored.quest_runner, "QuestRunner must retain recovery ownership until city healing completes.")

func restore_snapshot(simulation, label: String):
	var captured: Dictionary = SimulationSnapshot.capture(simulation)
	if not str(captured.get("error", "")).is_empty():
		failures += 1
	assert(str(captured.get("error", "")).is_empty(), "Snapshot capture must succeed for %s: %s" % [label, str(captured.get("error", ""))])
	var result: Dictionary = SimulationSnapshot.restore(captured)
	if not str(result.get("error", "")).is_empty():
		failures += 1
	assert(str(result.get("error", "")).is_empty(), "Snapshot restore must succeed for %s: %s" % [label, str(result.get("error", ""))])
	var restored = result.get("simulation")
	assert(restored != null and restored != simulation, "Snapshot restore must return a detached Simulation for %s." % label)
	assert_snapshot_equal(simulation, restored, "immediately after restoring " + label)
	return restored

func assert_snapshot_equal(original, restored, label: String) -> void:
	var original_snapshot: Dictionary = SimulationSnapshot.capture(original)
	var restored_snapshot: Dictionary = SimulationSnapshot.capture(restored)
	assert(str(original_snapshot.get("error", "")).is_empty() and str(restored_snapshot.get("error", "")).is_empty(), "Both snapshots must remain capturable %s." % label)
	if original_snapshot != restored_snapshot:
		failures += 1
		printerr("FAIL: complete snapshot differs " + label)
		for index in mini(original_snapshot.nodes.size(), restored_snapshot.nodes.size()):
			if original_snapshot.nodes[index] != restored_snapshot.nodes[index]:
				printerr("First differing node: ", index, " original=", original_snapshot.nodes[index], " restored=", restored_snapshot.nodes[index])
				break
	var original_fields := stable_snapshot_fields(original)
	var restored_fields := stable_snapshot_fields(restored)
	if original_fields != restored_fields:
		failures += 1
		printerr("Snapshot stable-field mismatch %s\nORIGINAL: %s\nRESTORED: %s" % [label, str(original_fields), str(restored_fields)])
	assert(original_fields == restored_fields, "Stable runtime fields must match %s." % label)

func stable_snapshot_fields(simulation) -> Dictionary:
	var active_dungeon_id := ""
	if simulation.dungeon_runner.active_dungeon != null:
		active_dungeon_id = simulation.dungeon_runner.active_dungeon.definition.id
	var active_event_id := ""
	if simulation.event_runner.active_event != null:
		active_event_id = simulation.event_runner.active_event.definition.id
	return {
		"world_tick": simulation.world_clock.world_tick,
		"loop_state": simulation.hero_state.loop_state,
		"hero_position": simulation.world_state.hero_position,
		"current_hp": simulation.hero_state.current_hp,
		"gold": simulation.hero_state.gold,
		"experience": simulation.hero_state.experience,
		"level": simulation.hero_state.level,
		"combat_results": simulation.combat_results_by_mob,
		"active_combat_context": simulation.active_combat_context,
		"active_dungeon_id": active_dungeon_id,
		"dungeon_encounters": simulation.dungeon_runner.ordinary_encounters_completed,
		"dungeon_respawn_ticks": simulation.dungeon_runner.respawn_ticks_remaining,
		"active_event_id": active_event_id,
		"event_stage_ticks": simulation.event_runner.current_stage_ticks_remaining,
		"event_respawn_ticks": simulation.event_runner.respawn_ticks_remaining,
		"quest_respawn_ticks": simulation.quest_runner.respawn_ticks_remaining,
		"travel_route": simulation.travel_system.get_route() if simulation.travel_system.is_travelling() else [],
		"travel_remaining": simulation.travel_system.get_remaining_steps(),
		"event_rng_state": simulation.event_runner.resolution_rng.state,
	}

func prepare_dungeon_at_entrance(simulation):
	var belt_definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var belt_rng := RandomNumberGenerator.new()
	belt_rng.seed = 8100
	var belt = simulation.item_generator.generate(belt_definition, 5, belt_rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.hero_state.inventory.add_healing_potion(5)
	simulation.hero_state.prepared_healing_potion_levels = [5]
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	assert(dungeon.discover("snapshot test"), "Dungeon fixture must discover a real map dungeon.")
	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Dungeon fixture must place the hero on the real dungeon hex.")
	assert(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, simulation.get_hero_power()), "Dungeon fixture must begin a real dungeon trip.")
	assert(bool(simulation.dungeon_runner.advance(simulation.hero_state).get("arrived", false)), "Dungeon fixture must arrive through DungeonRunner.")
	assert(simulation.dungeon_runner.enter(simulation.hero_state), "Dungeon fixture must enter through DungeonRunner.")
	return dungeon

func create_started_old_clearing(seed: int):
	var simulation = SimulationScript.new(seed, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	var definition = simulation.event_system.get_definition_by_id("old_clearing_ambush")
	assert(definition != null and simulation.event_system.spawn_definition(definition, simulation.hex_map.definition.starting_city_center, 100), "Event fixture must spawn an authored temporary event.")
	var event_instance = simulation.event_system.get_active_events()[0]
	assert(simulation.quest_pool.assign_map_targets_to_current_offers(), "Event fixture must place an interrupted real quest route.")
	simulation.quest_runner.quest_definition = simulation.quest_pool.get_available_quests()[0]
	var selection_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats)
	assert(selection_event != null and simulation.travel_system.is_travelling(), "Event fixture must start real quest travel before interruption.")
	simulation.pending_event_instance = event_instance
	assert(simulation.begin_pending_event_if_ready(100), "Event fixture must begin the authored event through Simulation.")
	return simulation

func advance_until_loop_state(simulation, expected_state, max_ticks: int) -> void:
	var ticks := 0
	while simulation.hero_state.loop_state != expected_state and ticks < max_ticks:
		simulation.advance_time(10.0)
		ticks += 1
	assert(simulation.hero_state.loop_state == expected_state, "Fixture did not reach the required real runtime state within its bound.")
