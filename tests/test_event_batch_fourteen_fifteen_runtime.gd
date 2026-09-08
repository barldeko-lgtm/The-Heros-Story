extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_14 := "res://data/events/starting_region/0014_medicine_before_sunset.tres"
const EVENT_15 := "res://data/events/starting_region/0015_signal_from_old_quarry.tres"

func _init() -> void:
	test_medicine_strength_delivery_moves_to_secondary()
	test_medicine_constitution_can_establish_generous_same_event()
	test_quarry_constitution_can_establish_cautious_and_avoid_combat()
	test_quarry_strength_fights_and_returns()
	print("PASS: Events 14-15 perform real secondary travel, same-event Generous/Cautious expression, Cave Lizard combat, rewards, return travel, and original-route resumption.")
	quit()

func test_medicine_strength_delivery_moves_to_secondary() -> void:
	var setup = create_started_event(11401, EVENT_14)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(s)
	set_primary_winner(s, "strength", false)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var encounter: Vector2i = event_instance.encounter_hex
	var detour_steps: int = s.hex_map.get_distance_steps(encounter, secondary)
	var gold_before: int = s.hero_state.gold
	var ticks_used: int = advance_until_complete_without_combat(s, 30)
	assert(ticks_used == 6 + detour_steps)
	assert(s.hero_state.gold == gold_before + 70)
	assert(s.hero_state.personality_axis_values["courage"] == 5)
	assert(event_instance.outcome_id == "essential_medicine_delivered")
	assert(s.world_state.hero_position == secondary, "Medicine event must end at its actual remote camp instead of teleporting back to the encounter.")
	assert_original_route_resumed(s, setup["original_destination"])

func test_medicine_constitution_can_establish_generous_same_event() -> void:
	var setup = create_started_event(11402, EVENT_14)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(s)
	s.trait_development.apply_movement(s.hero_state, "greed", 35)
	set_primary_winner(s, "constitution", false)
	var secondary: Vector2i = event_instance.secondary_target_hex
	var encounter: Vector2i = event_instance.encounter_hex
	var detour_steps: int = s.hex_map.get_distance_steps(encounter, secondary)
	var gold_before: int = s.hero_state.gold
	var ticks_used: int = advance_until_complete_without_combat(s, 40)
	assert(ticks_used == 10 + detour_steps)
	assert(s.hero_state.personality_axis_values["greed"] == 40)
	assert(s.trait_development.has_trait(s.hero_state, "generous"), "CON formative help must be able to establish Generous before the destination check.")
	assert(s.hero_state.gold == gold_before + 20)
	assert(event_instance.outcome_id == "full_medicine_shipment_delivered_generously")
	assert(s.world_state.hero_position == secondary)
	assert_original_route_resumed(s, setup["original_destination"])

func test_quarry_constitution_can_establish_cautious_and_avoid_combat() -> void:
	var setup = create_started_event(11501, EVENT_15)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(s)
	s.trait_development.apply_movement(s.hero_state, "courage", -35)
	set_primary_winner(s, "constitution", false)
	var encounter: Vector2i = event_instance.encounter_hex
	var detour_steps: int = s.hex_map.get_distance_steps(encounter, event_instance.secondary_target_hex)
	var gold_before: int = s.hero_state.gold
	var xp_before: int = s.hero_state.experience
	var ticks_used: int = advance_until_complete_without_combat(s, 50)
	assert(ticks_used == 11 + detour_steps * 2)
	assert(s.hero_state.personality_axis_values["courage"] == -40)
	assert(s.trait_development.has_trait(s.hero_state, "cautious"), "CON preparation must establish Cautious before the same event's quarry check.")
	assert(s.hero_state.gold == gold_before + 70 and s.hero_state.experience == xp_before)
	assert(event_instance.outcome_id == "quarry_worker_rescued_cautiously")
	assert(s.world_state.hero_position == encounter, "Cautious quarry rescue must physically return to the encounter point.")
	assert_original_route_resumed(s, setup["original_destination"])

func test_quarry_strength_fights_and_returns() -> void:
	var setup = create_started_event(11502, EVENT_15)
	var s = setup["simulation"]
	var event_instance = setup["event"]
	reset_personality(s)
	set_primary_winner(s, "strength", true)
	var encounter: Vector2i = event_instance.encounter_hex
	var secondary: Vector2i = event_instance.secondary_target_hex
	var xp_before: int = s.hero_state.experience
	var gold_before: int = s.hero_state.gold
	assert(advance_until_combat(s, 30) > 0)
	assert(s.world_state.hero_position == secondary)
	assert(s.event_runner.get_current_mob_definition().id == "cave_lizard")
	s.start_event_combat()
	assert(s.active_combat_session != null)
	assert(is_equal_approx(s.active_combat_session.mob_remaining_hp, s.active_combat_session.mob_stats.max_hp))
	s.advance_active_combat(1000000.0)
	assert(s.hero_state.loop_state != s.hero_state.DEAD_RESPAWNING)
	assert(s.hero_state.experience == xp_before + 190)
	advance_until_complete_without_combat(s, 40)
	assert(s.hero_state.gold == gold_before + 70)
	assert(s.hero_state.personality_axis_values["courage"] == 5)
	assert(event_instance.outcome_id == "quarry_worker_rescued_after_fight")
	assert(s.world_state.hero_position == encounter)
	assert_original_route_resumed(s, setup["original_destination"])

func create_started_event(seed: int, event_path: String) -> Dictionary:
	var s = SimulationScript.new(seed, null, [], true)
	s.quest_pool.release_available_offer_map_targets()
	s.event_system.clear_instances()
	var definition = load(event_path)
	assert(definition != null and definition.validate_definition())
	s.event_system.set_definitions([definition])
	var city: Vector2i = s.hex_map.definition.starting_city_center
	assert(s.event_system.spawn_definition(definition, city, 100), "Target event must have a valid primary/secondary placement pair: %s" % definition.id)
	var event_instance = s.event_system.get_active_events()[0]
	assert(event_instance != null and event_instance.has_secondary_target())
	assert_secondary_placement(s, event_instance, city)
	assert(s.world_state.set_hero_position(event_instance.target_hex))
	assert(s.travel_system.begin_travel(city))
	s.hero_state.loop_state = s.hero_state.TRAVEL_TO_QUEST
	var original_destination: Vector2i = s.travel_system.destination
	assert(s.event_system.engage(event_instance, 100))
	var begin_result: Dictionary = s.event_runner.begin(s.hero_state, event_instance)
	assert(not begin_result.is_empty() and s.travel_system.has_suspended_travel())
	return {"simulation": s, "event": event_instance, "original_destination": original_destination}

func assert_secondary_placement(s, event_instance, city: Vector2i) -> void:
	var definition = event_instance.definition
	var primary_distance: int = s.hex_map.get_distance_steps(city, event_instance.target_hex)
	var secondary_distance: int = s.hex_map.get_distance_steps(city, event_instance.secondary_target_hex)
	var between_distance: int = s.hex_map.get_distance_steps(event_instance.target_hex, event_instance.secondary_target_hex)
	assert(primary_distance >= definition.placement_distance_hex_min and primary_distance <= definition.placement_distance_hex_max)
	assert(secondary_distance >= definition.secondary_target_distance_hex_min and secondary_distance <= definition.secondary_target_distance_hex_max)
	assert(between_distance >= definition.secondary_target_distance_from_event_hex_min and between_distance <= definition.secondary_target_distance_from_event_hex_max)
	assert(secondary_distance > primary_distance)
	var secondary_hex = s.hex_map.get_hex(event_instance.secondary_target_hex)
	if not definition.secondary_target_allowed_terrain_ids.is_empty():
		assert(definition.secondary_target_allowed_terrain_ids.has(secondary_hex.terrain_id))
	for tag in definition.secondary_target_forbidden_tags:
		assert(not secondary_hex.has_tag(tag))

func reset_personality(s) -> void:
	s.trait_development.reset_state(s.hero_state)

func set_primary_winner(s, attribute_id: String, combat_ready: bool) -> void:
	s.hero_state.strength = 300 if combat_ready else 5
	s.hero_state.dexterity = 5
	s.hero_state.constitution = 300 if combat_ready else 5
	s.hero_state.wisdom = 5
	if attribute_id == "strength":
		s.hero_state.strength = 500 if combat_ready else 40
	elif attribute_id == "constitution":
		s.hero_state.constitution = 500 if combat_ready else 40
	s.refresh_combat_stats()
	s.hero_state.current_hp = s.combat_stats.max_hp

func advance_until_combat(s, max_ticks: int) -> int:
	var ticks := 0
	while s.event_runner.active_event != null and s.hero_state.loop_state != s.hero_state.EVENT_COMBAT and ticks < max_ticks:
		ticks += 1
		s.advance_event_tick(1000 + ticks)
	assert(s.event_runner.active_event != null and s.hero_state.loop_state == s.hero_state.EVENT_COMBAT)
	return ticks

func advance_until_complete_without_combat(s, max_ticks: int) -> int:
	var ticks := 0
	while s.event_runner.active_event != null and ticks < max_ticks:
		assert(s.hero_state.loop_state != s.hero_state.EVENT_COMBAT, "Expected a non-combat continuation but event entered combat.")
		ticks += 1
		s.advance_event_tick(2000 + ticks)
	assert(s.event_runner.active_event == null, "Event did not complete inside the expected tick budget.")
	return ticks

func assert_original_route_resumed(s, original_destination: Vector2i) -> void:
	assert(s.hero_state.loop_state == s.hero_state.TRAVEL_TO_QUEST)
	assert(s.travel_system.destination == original_destination and s.travel_system.is_travelling())

