extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_1 := "res://data/events/mid_region/0001_missing_garrison_pay.tres"
const EVENT_2 := "res://data/events/mid_region/0002_silent_signal_post.tres"
const EVENT_3 := "res://data/events/mid_region/0003_charcoal_burners_dispute.tres"
const EVENT_4 := "res://data/events/mid_region/0004_isolated_logging_camp.tres"
const EVENT_5 := "res://data/events/mid_region/0005_false_toll_at_pass.tres"

func _init() -> void:
	test_missing_pay_noble_route()
	test_signal_post_conservative_detour_and_combat()
	test_charcoal_devious_route()
	test_logging_camp_generous_detour()
	test_false_toll_devious_combat()
	print("PASS: Mid Region events 1-5 execute representative local, detour and combat branches with authored personality movement, rewards and route resumption.")
	quit()

func test_missing_pay_noble_route() -> void:
	var setup = create_started_event(22001, EVENT_1)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "constitution", false)
	var gold_before: int = simulation.hero_state.gold
	advance_until_complete_without_combat(simulation, 30)
	assert(simulation.hero_state.personality_axis_values["morality"] == 5)
	assert(simulation.hero_state.gold == gold_before + 140)
	assert(setup["event"].outcome_id == "garrison_pay_restored_fairly")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_signal_post_conservative_detour_and_combat() -> void:
	var setup = create_started_event(22002, EVENT_2)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(simulation)
	set_primary_winner(simulation, "wisdom", true)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 50) > 0)
	assert(simulation.world_state.hero_position == secondary)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == -5)
	assert_event_combat_and_win(simulation, "veteran_bandit", 0.75)
	assert(simulation.hero_state.experience == xp_before + 275)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 220)
	assert(event_instance.outcome_id == "signal_post_retaken_carefully")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_charcoal_devious_route() -> void:
	var setup = create_started_event(22003, EVENT_3)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "dexterity", false)
	var gold_before: int = simulation.hero_state.gold
	advance_until_complete_without_combat(simulation, 30)
	assert(simulation.hero_state.personality_axis_values["morality"] == -5)
	assert(simulation.hero_state.gold == gold_before + 230)
	assert(setup["event"].outcome_id == "charcoal_tally_manipulated")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_logging_camp_generous_detour() -> void:
	var setup = create_started_event(22004, EVENT_4)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(simulation)
	set_primary_winner(simulation, "strength", false)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var gold_before: int = simulation.hero_state.gold
	advance_until_complete_without_combat(simulation, 50)
	assert(simulation.world_state.hero_position == secondary)
	assert(simulation.hero_state.personality_axis_values["greed"] == 5)
	assert(simulation.hero_state.gold == gold_before + 100)
	assert(event_instance.outcome_id == "logging_camp_supplied_generously")
	assert_original_route_resumed(simulation, setup["original_destination"])

func test_false_toll_devious_combat() -> void:
	var setup = create_started_event(22005, EVENT_5)
	var simulation = setup["simulation"]
	reset_personality(simulation)
	set_primary_winner(simulation, "dexterity", true)
	var xp_before: int = simulation.hero_state.experience
	var gold_before: int = simulation.hero_state.gold
	assert(advance_until_combat(simulation, 30) > 0)
	assert(simulation.hero_state.personality_axis_values["morality"] == -5)
	assert_event_combat_and_win(simulation, "hardened_mercenary", 0.70)
	assert(simulation.hero_state.experience == xp_before + 330)
	advance_until_complete_without_combat(simulation, 10)
	assert(simulation.hero_state.gold == gold_before + 260)
	assert(setup["event"].outcome_id == "false_toll_broken_by_deception")
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
		simulation.advance_event_tick(3000 + ticks)
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
		simulation.advance_event_tick(4000 + ticks)
	assert(simulation.event_runner.active_event == null, "Event did not complete inside the expected tick budget.")
	return ticks

func assert_original_route_resumed(simulation, original_destination: Vector2i) -> void:
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)
	assert(simulation.travel_system.destination == original_destination and simulation.travel_system.is_travelling())
