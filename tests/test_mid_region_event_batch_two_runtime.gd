extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_6 := "res://data/events/mid_region/0006_wargs_at_supply_wagon.tres"
const EVENT_7 := "res://data/events/mid_region/0007_blood_at_resin_kilns.tres"
const EVENT_8 := "res://data/events/mid_region/0008_surveyors_lost_case.tres"
const EVENT_9 := "res://data/events/mid_region/0009_beast_at_mountain_cistern.tres"
const EVENT_10 := "res://data/events/mid_region/0010_water_from_old_channel.tres"

func _init() -> void:
	test_supply_wagon_devious_combat()
	test_resin_kilns_curious_combat()
	test_surveyor_generous_round_trip()
	test_cistern_greedy_combat()
	test_old_channel_curious_route()
	print("PASS: Mid Region events 6-10 execute representative combat, local and round-trip detour branches with authored personality movement, rewards, XP and route resumption.")
	quit()

func test_supply_wagon_devious_combat() -> void:
	var setup = create_started_event(24001, EVENT_6)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "dexterity", true)
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 30) > 0)
	assert(simulation.hero_state.personality_axis_values["morality"] == -5)
	assert_event_combat_and_win(simulation, "warg_pack_leader", 0.70)
	assert(simulation.hero_state.experience == xp_before + 300)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 280)
	assert(setup["event"].outcome_id == "supply_wagon_saved_by_deception")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_resin_kilns_curious_combat() -> void:
	var setup = create_started_event(24002, EVENT_7)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "wisdom", true)
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 30) > 0)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 5)
	assert_event_combat_and_win(simulation, "orc_berserker", 0.75)
	assert(simulation.hero_state.experience == xp_before + 315)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 280)
	assert(setup["event"].outcome_id == "resin_workers_saved_by_tracking")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_surveyor_generous_round_trip() -> void:
	var setup = create_started_event(24003, EVENT_8)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(simulation)
	set_primary_winner(simulation, "strength", false)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var encounter: Vector2i = event_instance.target_hex
	var gold_before: int = simulation.hero_state.gold
	var reached_secondary := false
	var ticks := 0
	while simulation.event_runner.active_event != null and ticks < 50:
		ticks += 1
		simulation.advance_event_tick(5000 + ticks)
		if simulation.world_state.hero_position == secondary:
			reached_secondary = true
			break
	assert(reached_secondary, "Surveyor event must physically reach its secondary map objective.")
	advance_until_complete_without_combat(simulation, 50)
	assert(simulation.world_state.hero_position == encounter, "Surveyor event must physically return to its encounter hex before resuming the interrupted route.")
	assert(simulation.hero_state.personality_axis_values["greed"] == 5)
	assert(simulation.hero_state.gold == gold_before + 80)
	assert(event_instance.outcome_id == "surveyors_case_returned_generously")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_cistern_greedy_combat() -> void:
	var setup = create_started_event(24004, EVENT_9)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "constitution", true)
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 30) > 0)
	assert(simulation.hero_state.personality_axis_values["greed"] == -5)
	assert_event_combat_and_win(simulation, "old_mountain_beast", 0.85)
	assert(simulation.hero_state.experience == xp_before + 290)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 320)
	assert(setup["event"].outcome_id == "cistern_beast_killed_for_hazard_pay")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_old_channel_curious_route() -> void:
	var setup = create_started_event(24005, EVENT_10)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "wisdom", false)
	var gold_before: int = simulation.hero_state.gold
	advance_until_complete_without_combat(simulation, 30)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 5)
	assert(simulation.hero_state.gold == gold_before + 200)
	assert(setup["event"].outcome_id == "old_channel_bypass_rediscovered")
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
		simulation.advance_event_tick(6000 + ticks)
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
		simulation.advance_event_tick(7000 + ticks)
	assert(simulation.event_runner.active_event == null, "Event did not complete inside the expected tick budget.")
	return ticks

func assert_original_route_resumed(simulation, original_destination: Vector2i) -> void:
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)
	assert(simulation.travel_system.destination == original_destination and simulation.travel_system.is_travelling())
