extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_forest_placement_at_spawn_gate()
	test_strength_fast_combat_branch()
	test_dexterity_standard_branch()
	test_wisdom_safe_branch()
	test_dexterity_can_establish_curiosity_for_stage_two()
	test_noble_stage_three_reward()
	test_curious_and_noble_stack_their_time_and_rewards()
	print("PASS: Poachers' Snares uses exact branch timing, live Wild Boar combat, immediate Curious expression, Noble expression, and normal equipment rewards.")
	quit()

func test_forest_placement_at_spawn_gate() -> void:
	var setup: Dictionary = create_started_event_simulation(9301, false)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var city: Vector2i = simulation.hex_map.definition.starting_city_center
	var event_hex = simulation.hex_map.get_hex(event_instance.target_hex)
	var distance: int = simulation.hex_map.get_distance_steps(city, event_instance.target_hex)
	assert(event_instance.spawn_tick == 100)
	assert(event_hex != null and event_hex.terrain_id == "forest")
	assert(distance >= 4 and distance <= 6)
	assert(not event_hex.has_tag("city"))
	assert(not event_instance.has_secondary_target())

func test_strength_fast_combat_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9302)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.hero_state.strength = 200
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 5
	simulation.refresh_combat_stats()
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience
	var starting_items: int = get_total_equipment_item_count(simulation)

	var ticks_before_combat: int = 0
	while simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT and ticks_before_combat < 20:
		ticks_before_combat += 1
		simulation.advance_event_tick(100 + ticks_before_combat)
	assert(ticks_before_combat == 3, "STR must enter Wild Boar combat after intro, formative decision, and direct approach.")
	assert(simulation.event_runner.get_current_mob_definition().id == "wild_boar")

	simulation.start_event_combat()
	simulation.advance_active_combat(1000.0)
	assert(simulation.hero_state.experience == starting_xp + 75)
	var ticks_after_combat: int = advance_until_event_complete(simulation, 40)
	assert(ticks_after_combat == 4, "STR base branch must total eight world ticks including its one combat tick.")
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(simulation.hero_state.personality_axis_values["courage"] == 5)
	assert(get_total_equipment_item_count(simulation) == starting_items, "Event Wild Boar combat must not roll ordinary mob equipment drops.")
	assert(event_instance.outcome_id == "ranger_freed")

func test_dexterity_standard_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9303)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 40
	simulation.hero_state.wisdom = 5
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete(simulation, 40)
	assert(ticks_used == 10)
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 5)
	assert(event_instance.outcome_id == "ranger_freed")

func test_wisdom_safe_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9304)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 40
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete(simulation, 40)
	assert(ticks_used == 11)
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	assert(event_instance.outcome_id == "ranger_freed")

func test_dexterity_can_establish_curiosity_for_stage_two() -> void:
	var setup: Dictionary = create_started_event_simulation(9305)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "curiosity", 35)
	assert(not simulation.trait_development.has_trait(simulation.hero_state, "curious"))
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 40
	simulation.hero_state.wisdom = 5
	var starting_gold: int = simulation.hero_state.gold
	var starting_items: int = get_total_equipment_item_count(simulation)

	var ticks_used: int = advance_until_event_complete(simulation, 40)
	assert(ticks_used == 12, "DEX +5 may establish Curious and immediately add the two-tick Stage 2 search in the same event.")
	assert(simulation.trait_development.has_trait(simulation.hero_state, "curious"))
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 40, "Expressive Curious must not reinforce itself after the formative +5.")
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(get_total_equipment_item_count(simulation) == starting_items + 1)
	assert(find_common_ilvl5_item(simulation) != null)
	assert(event_instance.outcome_id == "ranger_freed_curious")

func test_noble_stage_three_reward() -> void:
	var setup: Dictionary = create_started_event_simulation(9306)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "morality", 40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "noble"))
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 40
	var starting_gold: int = simulation.hero_state.gold

	var ticks_used: int = advance_until_event_complete(simulation, 40)
	assert(ticks_used == 13, "Noble must add exactly two detention ticks to the eleven-tick WIS base branch.")
	assert(simulation.hero_state.gold == starting_gold + 75)
	assert(simulation.hero_state.personality_axis_values["morality"] == 40, "Expressive Noble must not reinforce itself.")
	assert(event_instance.outcome_id == "poacher_detained")

func test_curious_and_noble_stack_their_time_and_rewards() -> void:
	var setup: Dictionary = create_started_event_simulation(9307)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "curiosity", 40)
	simulation.trait_development.apply_movement(simulation.hero_state, "morality", 40)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 40
	var starting_gold: int = simulation.hero_state.gold
	var starting_items: int = get_total_equipment_item_count(simulation)

	var ticks_used: int = advance_until_event_complete(simulation, 40)
	assert(ticks_used == 15)
	assert(simulation.hero_state.gold == starting_gold + 75)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 40)
	assert(simulation.hero_state.personality_axis_values["morality"] == 40)
	assert(get_total_equipment_item_count(simulation) == starting_items + 1)
	assert(find_common_ilvl5_item(simulation) != null)
	assert(event_instance.outcome_id == "poacher_detained_curious")

func create_started_event_simulation(seed: int, engage_event: bool = true) -> Dictionary:
	var simulation = SimulationScript.new(seed, null, [], true)
	assert(simulation.event_system.get_active_events().is_empty())
	simulation.quest_pool.release_available_offer_map_targets()
	var spawned_events: Array = simulation.event_system.spawn_initial_population_if_ready(100)
	var event_instance = find_event_by_id(spawned_events, "poachers_snares")
	assert(event_instance != null, "Poachers' Snares must find a valid forest placement at distance 4..6 once the event gate opens.")
	assert(simulation.quest_pool.assign_map_targets_to_current_offers())
	if not engage_event:
		return {"simulation": simulation, "event": event_instance}

	var available_quests: Array = simulation.quest_pool.get_available_quests()
	assert(not available_quests.is_empty())
	simulation.quest_runner.quest_definition = available_quests[0]
	var selection_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats)
	assert(selection_event != null and simulation.travel_system.is_travelling())
	assert(simulation.world_state.set_hero_position(event_instance.target_hex))
	simulation.pending_event_instance = event_instance
	assert(simulation.begin_pending_event_if_ready(100))
	assert(simulation.travel_system.has_suspended_travel())
	return {"simulation": simulation, "event": event_instance}

func prepare_personality(simulation) -> void:
	simulation.trait_development.reset_state(simulation.hero_state)

func advance_until_event_complete(simulation, max_ticks: int) -> int:
	var ticks_used: int = 0
	while simulation.event_runner.active_event != null and ticks_used < max_ticks:
		assert(simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT, "Non-combat helper encountered an unexpected combat stage.")
		ticks_used += 1
		simulation.advance_event_tick(300 + ticks_used)
	assert(simulation.event_runner.active_event == null)
	return ticks_used

func find_event_by_id(events: Array, event_id: String):
	for event_instance in events:
		if event_instance != null and event_instance.definition != null and event_instance.definition.id == event_id:
			return event_instance
	return null

func get_total_equipment_item_count(simulation) -> int:
	return simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()

func find_common_ilvl5_item(simulation):
	for item in simulation.hero_state.inventory.get_items():
		if item != null and item.item_level == 5 and item.rarity == 0:
			return item
	for item in simulation.hero_state.equipment.get_all_items():
		if item != null and item.item_level == 5 and item.rarity == 0:
			return item
	return null

