extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_16 := "res://data/events/starting_region/0016_scattered_earnings.tres"
const EVENT_19 := "res://data/events/starting_region/0019_parcel_for_forester.tres"
const EVENT_20 := "res://data/events/starting_region/0020_old_hunters_cache.tres"

func _init() -> void:
	test_local_devious_branch()
	test_forester_generous_detour()
	test_hunter_generous_detour_and_return()
	print("PASS: Events 16-20 apply the intended underrepresented personality movement, stay non-combat, and both authored detours use real map travel with route resumption.")
	quit()

func test_local_devious_branch() -> void:
	var setup = create_started_event(11601, EVENT_16, false)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	s.trait_development.reset_state(s.hero_state)
	set_primary_winner(s, "dexterity")
	var gold_before: int = s.hero_state.gold
	var result: Dictionary = advance_until_complete(s, event_instance, 20)
	assert(not result["saw_combat"])
	assert(s.hero_state.personality_axis_values["morality"] == -5)
	assert(s.hero_state.gold == gold_before + 80)
	assert(event_instance.outcome_id == "earnings_partly_hidden")
	assert(s.world_state.hero_position == event_instance.encounter_hex)
	assert_original_route_resumed(s, setup["original_destination"])

func test_forester_generous_detour() -> void:
	var setup = create_started_event(11901, EVENT_19, true)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	s.trait_development.reset_state(s.hero_state)
	set_primary_winner(s, "dexterity")
	var gold_before: int = s.hero_state.gold
	var result: Dictionary = advance_until_complete(s, event_instance, 30)
	assert(not result["saw_combat"] and result["visited_secondary"])
	assert(s.hero_state.personality_axis_values["greed"] == 5)
	assert(s.hero_state.gold == gold_before + 20)
	assert(event_instance.outcome_id == "forester_parcel_delivered_generously")
	assert(s.world_state.hero_position == event_instance.secondary_target_hex)
	assert_original_route_resumed(s, setup["original_destination"])

func test_hunter_generous_detour_and_return() -> void:
	var setup = create_started_event(12001, EVENT_20, true)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	s.trait_development.reset_state(s.hero_state)
	set_primary_winner(s, "constitution")
	var gold_before: int = s.hero_state.gold
	var result: Dictionary = advance_until_complete(s, event_instance, 40)
	assert(not result["saw_combat"] and result["visited_secondary"])
	assert(s.hero_state.personality_axis_values["greed"] == 5)
	assert(s.hero_state.gold == gold_before + 20)
	assert(event_instance.outcome_id == "hunter_cache_returned_generously")
	assert(s.world_state.hero_position == event_instance.encounter_hex)
	assert_original_route_resumed(s, setup["original_destination"])

func create_started_event(seed: int, event_path: String, expect_secondary: bool) -> Dictionary:
	var s = SimulationScript.new(seed, null, [], true)
	s.quest_pool.release_available_offer_map_targets()
	s.event_system.clear_instances()
	var definition = load(event_path)
	assert(definition != null and definition.validate_definition())
	s.event_system.set_definitions([definition])
	var city: Vector2i = s.hex_map.definition.starting_city_center
	assert(s.event_system.spawn_definition(definition, city, 100), "Event must have a valid map placement: %s" % definition.id)
	var event_instance = s.event_system.get_active_events()[0]
	assert(event_instance.has_secondary_target() == expect_secondary)
	assert(s.world_state.set_hero_position(event_instance.target_hex))
	assert(s.travel_system.begin_travel(city))
	s.hero_state.loop_state = s.hero_state.TRAVEL_TO_QUEST
	var original_destination: Vector2i = s.travel_system.destination
	assert(s.event_system.engage(event_instance, 100))
	var begin_result: Dictionary = s.event_runner.begin(s.hero_state, event_instance)
	assert(not begin_result.is_empty() and s.travel_system.has_suspended_travel())
	return {"simulation": s, "event": event_instance, "original_destination": original_destination}

func set_primary_winner(s, attribute_id: String) -> void:
	s.hero_state.strength = 5
	s.hero_state.dexterity = 5
	s.hero_state.constitution = 5
	s.hero_state.wisdom = 5
	match attribute_id:
		"strength": s.hero_state.strength = 40
		"dexterity": s.hero_state.dexterity = 40
		"constitution": s.hero_state.constitution = 40
		"wisdom": s.hero_state.wisdom = 40
	s.refresh_combat_stats()
	s.hero_state.current_hp = s.combat_stats.max_hp

func advance_until_complete(s, event_instance, max_ticks: int) -> Dictionary:
	var ticks := 0
	var visited_secondary := false
	var saw_combat := false
	while s.event_runner.active_event != null and ticks < max_ticks:
		if s.hero_state.loop_state == s.hero_state.EVENT_COMBAT:
			saw_combat = true
			break
		ticks += 1
		s.advance_event_tick(3000 + ticks)
		if event_instance.has_secondary_target() and s.world_state.hero_position == event_instance.secondary_target_hex:
			visited_secondary = true
	assert(s.event_runner.active_event == null, "Non-combat balancing event must complete within the bounded tick budget.")
	return {"visited_secondary": visited_secondary, "saw_combat": saw_combat}

func assert_original_route_resumed(s, original_destination: Vector2i) -> void:
	assert(s.hero_state.loop_state == s.hero_state.TRAVEL_TO_QUEST)
	assert(s.travel_system.destination == original_destination and s.travel_system.is_travelling())
