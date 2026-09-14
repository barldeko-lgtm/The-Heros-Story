extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_11 := "res://data/events/mid_region/0011_wagon_in_flooded_hollow.tres"
const EVENT_12 := "res://data/events/mid_region/0012_orc_at_field_granary.tres"
const EVENT_13 := "res://data/events/mid_region/0013_smoke_beyond_firebreak.tres"
const EVENT_14 := "res://data/events/mid_region/0014_shaman_at_thunder_stone.tres"
const EVENT_15 := "res://data/events/mid_region/0015_bell_on_far_ridge.tres"

func _init() -> void:
	test_flooded_wagon_conservative_route()
	test_field_granary_cautious_combat()
	test_firebreak_generous_detour()
	test_thunder_stone_devious_combat()
	test_far_ridge_curious_round_trip()
	print("PASS: Mid Region events 11-15 execute local, combat, one-way detour and round-trip branches with the authored personality movement, rewards and route resumption.")
	quit()

func test_flooded_wagon_conservative_route() -> void:
	var setup = create_started_event(26001, EVENT_11)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "wisdom", false)
	var gold_before: int = simulation.hero_state.gold
	advance_until_complete_without_combat(simulation, 30)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == -5)
	assert(simulation.hero_state.gold == gold_before + 170)
	assert(setup["event"].outcome_id == "flooded_wagon_moved_by_known_route")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_field_granary_cautious_combat() -> void:
	var setup = create_started_event(26002, EVENT_12)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "constitution", true)
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 30) > 0)
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	assert_event_combat_and_win(simulation, "hardened_orc_raider", 0.80)
	assert(simulation.hero_state.experience == xp_before + 250)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 240)
	assert(setup["event"].outcome_id == "field_granary_defended_from_barricade")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_firebreak_generous_detour() -> void:
	var setup = create_started_event(26003, EVENT_13)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(simulation)
	set_primary_winner(simulation, "constitution", false)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var gold_before: int = simulation.hero_state.gold
	advance_until_complete_without_combat(simulation, 50)
	assert(simulation.world_state.hero_position == secondary, "Firebreak event must finish at its real secondary work camp.")
	assert(simulation.hero_state.personality_axis_values["greed"] == 5)
	assert(simulation.hero_state.gold == gold_before + 70)
	assert(event_instance.outcome_id == "forest_fire_helped_generously")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_thunder_stone_devious_combat() -> void:
	var setup = create_started_event(26004, EVENT_14)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "dexterity", true)
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 30) > 0)
	assert(simulation.hero_state.personality_axis_values["morality"] == -5)
	assert_event_combat_and_win(simulation, "storm_shaman", 0.70)
	assert(simulation.hero_state.experience == xp_before + 380)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 330)
	assert(setup["event"].outcome_id == "thunder_stone_shaman_lured_into_rockfall")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_far_ridge_curious_round_trip() -> void:
	var setup = create_started_event(26005, EVENT_15)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(simulation)
	set_primary_winner(simulation, "wisdom", false)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var encounter: Vector2i = event_instance.target_hex
	var gold_before: int = simulation.hero_state.gold
	var reached_secondary := false
	var ticks := 0
	while simulation.event_runner.active_event != null and ticks < 50:
		ticks += 1
		simulation.advance_event_tick(8000 + ticks)
		if simulation.world_state.hero_position == secondary:
			reached_secondary = true
			break
	assert(reached_secondary, "Far-ridge bell event must physically reach its secondary map objective.")
	advance_until_complete_without_combat(simulation, 50)
	assert(simulation.world_state.hero_position == encounter, "Far-ridge bell event must return to the encounter hex before route resumption.")
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 5)
	assert(simulation.hero_state.gold == gold_before + 210)
	assert(event_instance.outcome_id == "ridge_bell_restored_with_old_counterweight")
	assert_original_route_resumed(simulation, setup["original_destination"])

func create_started_event(seed: int, event_path: String) -> Dictionary:
	var simulation = SimulationScript.new(seed, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	simulation.event_system.clear_instances()
	var definition = load(event_path)
	assert(definition != null and definition.validate_definition())
	simulation.event_system.set_definitions([definition])
	var origin: Vector2i = simulation.hex_map.definition.mid_city_center
	assert(simulation.event_system.spawn_definition(definition, origin, 100), "Mid Region event must have a valid placement: %s" % definition.id)
	var event_instance = simulation.event_system.get_active_events()[0]
	assert(event_instance != null and event_instance.definition.id == definition.id)
	assert(simulation.world_state.set_hero_position(event_instance.target_hex))
	assert(simulation.travel_system.begin_travel(origin))
	simulation.hero_state.loop_state = simulation.hero_state.TRAVEL_TO_QUEST
	var original_destination: Vector2i = simulation.travel_system.destination
	assert(simulation.event_system.engage(event_instance, 100))
	var begin_result: Dictionary = simulation.event_runner.begin(simulation.hero_state, event_instance)
	assert(not begin_result.is_empty() and simulation.travel_system.has_suspended_travel())
	return {"simulation": simulation, "event": event_instance, "original_destination": original_destination}

func reset_personality(simulation) -> void:
	simulation.trait_development.reset_state(simulation.hero_state)

func set_primary_winner(simulation, attribute_id: String, combat_ready: bool) -> void:
	var baseline: int = 300 if combat_ready else 5
	var winner: int = 500 if combat_ready else 40
	simulation.hero_state.strength = baseline
	simulation.hero_state.dexterity = baseline
	simulation.hero_state.constitution = baseline
	simulation.hero_state.wisdom = baseline
	match attribute_id:
		"strength":
			simulation.hero_state.strength = winner
		"dexterity":
			simulation.hero_state.dexterity = winner
		"constitution":
			simulation.hero_state.constitution = winner
		"wisdom":
			simulation.hero_state.wisdom = winner
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp

func advance_until_combat(simulation, max_ticks: int) -> int:
	var ticks := 0
	while simulation.event_runner.active_event != null and simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT and ticks < max_ticks:
		ticks += 1
		simulation.advance_event_tick(9000 + ticks)
	assert(simulation.event_runner.active_event != null and simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	return ticks

func assert_event_combat_and_win(simulation, mob_id: String, hp_ratio: float) -> void:
	assert(simulation.event_runner.get_current_mob_definition().id == mob_id)
	simulation.start_event_combat()
	assert(simulation.active_combat_session != null)
	assert(is_equal_approx(
		simulation.active_combat_session.mob_remaining_hp,
		simulation.active_combat_session.mob_stats.max_hp * hp_ratio
	))
	simulation.advance_active_combat(1000000.0)
	assert(simulation.hero_state.loop_state != simulation.hero_state.DEAD_RESPAWNING)

func advance_until_complete_without_combat(simulation, max_ticks: int) -> int:
	var ticks := 0
	while simulation.event_runner.active_event != null and ticks < max_ticks:
		assert(simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT, "Expected non-combat continuation but event entered combat.")
		ticks += 1
		simulation.advance_event_tick(10000 + ticks)
	assert(simulation.event_runner.active_event == null, "Event did not complete inside the expected tick budget.")
	return ticks

func assert_original_route_resumed(simulation, original_destination: Vector2i) -> void:
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)
	assert(simulation.travel_system.destination == original_destination and simulation.travel_system.is_travelling())
