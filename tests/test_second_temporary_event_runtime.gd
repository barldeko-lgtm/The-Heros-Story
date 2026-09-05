extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_map_pair_placement()
	test_dexterity_fast_combat_branch()
	test_wisdom_safe_branch()
	test_constitution_late_branch()
	test_greedy_stash_branch()
	print("PASS: Smoke Over Old Tower uses real detour travel, branch timing, Bandit combat, Greedy reward, return travel, and original-route resumption.")
	quit()

func test_map_pair_placement() -> void:
	var setup: Dictionary = create_started_event_simulation(9201, false)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var city: Vector2i = simulation.hex_map.definition.starting_city_center
	var event_hex = simulation.hex_map.get_hex(event_instance.target_hex)
	var event_city_distance: int = simulation.hex_map.get_distance_steps(city, event_instance.target_hex)
	var tower_city_distance: int = simulation.hex_map.get_distance_steps(city, event_instance.secondary_target_hex)
	var event_to_tower_distance: int = simulation.hex_map.get_distance_steps(event_instance.target_hex, event_instance.secondary_target_hex)
	assert(event_hex != null and event_hex.terrain_id == "hill", "The wounded patrolman event center must be on hills.")
	assert(event_city_distance >= 3 and event_city_distance <= 5)
	assert(tower_city_distance >= 5 and tower_city_distance <= 7)
	assert(tower_city_distance > event_city_distance, "The tower must always be farther from Starting City than the event center.")
	assert(event_to_tower_distance >= 2 and event_to_tower_distance <= 4, "The tower must be a real 2..4-hex detour from the event center.")
	assert(not simulation.hex_map.get_hex(event_instance.secondary_target_hex).has_tag("city"), "The old tower must never be placed in a city hex.")
	assert(event_instance.has_secondary_target(), "The tower must own one reserved secondary map target before encounter resolution.")
	assert(simulation.world_state.get_activity_id_at_hex(event_instance.secondary_target_hex) == event_instance.secondary_map_activity_id)

func test_dexterity_fast_combat_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9202)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var original_quest_destination: Vector2i = setup["original_destination"]
	var encounter_hex: Vector2i = event_instance.encounter_hex
	var tower_hex: Vector2i = event_instance.secondary_target_hex
	var detour_steps: int = simulation.hex_map.get_distance_steps(encounter_hex, tower_hex)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 120
	simulation.hero_state.dexterity = 200
	simulation.hero_state.constitution = 5
	simulation.hero_state.wisdom = 5
	simulation.refresh_combat_stats()
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience
	var starting_items: int = get_total_equipment_item_count(simulation)

	var authored_ticks_before_combat: int = 0
	while simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT and authored_ticks_before_combat < 20:
		authored_ticks_before_combat += 1
		simulation.advance_event_tick(100 + authored_ticks_before_combat)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	assert(simulation.world_state.hero_position == tower_hex, "DEX branch must physically reach the tower before combat.")
	assert(simulation.event_runner.get_current_mob_definition().id == "bandit")
	assert(authored_ticks_before_combat == 3 + detour_steps, "DEX must spend intro + decision + real outbound travel + arrival before combat.")

	simulation.start_event_combat()
	assert(simulation.active_combat_session != null)
	simulation.advance_active_combat(1000.0)
	assert(simulation.hero_state.experience == starting_xp + 90, "Winning the existing Bandit fight must grant its normal 90 XP.")
	assert(simulation.event_runner.active_event != null)

	var post_combat_ticks: int = advance_until_event_complete(simulation, 200)
	assert(post_combat_ticks == 3 + detour_steps, "After combat DEX must free the patrolman, check Greedy, travel back, and turn in.")
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(simulation.hero_state.personality_axis_values["courage"] == 5)
	assert(get_total_equipment_item_count(simulation) == starting_items, "Non-Greedy DEX combat must not roll an ordinary mob equipment drop.")
	assert(event_instance.outcome_id == "fast_rescue")
	assert(simulation.world_state.hero_position == encounter_hex, "Event completion must occur after the real return trip to the encounter point.")
	assert(simulation.travel_system.destination == original_quest_destination and simulation.travel_system.is_travelling(), "The interrupted quest route must resume from the returned encounter hex.")

func test_wisdom_safe_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9203)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var encounter_hex: Vector2i = event_instance.encounter_hex
	var detour_steps: int = simulation.hex_map.get_distance_steps(encounter_hex, event_instance.secondary_target_hex)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.constitution = 5
	simulation.hero_state.wisdom = 40
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete(simulation, 100)
	assert(ticks_used == 9 + detour_steps * 2, "WIS must pay 1 track tick + 3 observation ticks and real travel both ways.")
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(simulation.hero_state.experience == starting_xp, "WIS branch avoids combat and therefore gains no Bandit XP.")
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	assert(event_instance.outcome_id == "careful_rescue")
	assert(simulation.world_state.hero_position == encounter_hex)

func test_constitution_late_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9204)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var encounter_hex: Vector2i = event_instance.encounter_hex
	var detour_steps: int = simulation.hex_map.get_distance_steps(encounter_hex, event_instance.secondary_target_hex)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.constitution = 40
	simulation.hero_state.wisdom = 5
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete(simulation, 100)
	assert(ticks_used == 7 + detour_steps * 2, "CON must pay two help ticks, find the second patrolman dead, return with the token, and turn in.")
	assert(simulation.hero_state.gold == starting_gold + 50)
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["morality"] == 5)
	assert(event_instance.outcome_id == "returned_patrol_token")
	assert(simulation.world_state.hero_position == encounter_hex)

func test_greedy_stash_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9205)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var encounter_hex: Vector2i = event_instance.encounter_hex
	var detour_steps: int = simulation.hex_map.get_distance_steps(encounter_hex, event_instance.secondary_target_hex)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.trait_development.apply_movement(simulation.hero_state, "greed", -40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "greedy"))
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.constitution = 5
	simulation.hero_state.wisdom = 40
	var starting_gold: int = simulation.hero_state.gold
	var starting_items: int = get_total_equipment_item_count(simulation)

	var ticks_used: int = advance_until_event_complete(simulation, 100)
	assert(ticks_used == 11 + detour_steps * 2, "Greedy WIS branch must add exactly two stash-search ticks.")
	assert(simulation.hero_state.gold == starting_gold + 50, "Greedy must not add extra Gold beyond the event's 50-Gold base reward.")
	assert(simulation.hero_state.personality_axis_values["greed"] == -40, "Expressive Greedy must not reinforce itself.")
	assert(get_total_equipment_item_count(simulation) == starting_items + 1)
	assert(find_common_ilvl10_item(simulation) != null, "Greedy stash must produce one guaranteed White/Common ilvl 10 item through the normal equipment pipeline.")
	assert(event_instance.outcome_id == "careful_rescue_greedy")
	assert(simulation.world_state.hero_position == encounter_hex)

func create_started_event_simulation(seed: int, engage_event: bool = true) -> Dictionary:
	var simulation = SimulationScript.new(seed, null, [], true)
	assert(simulation.event_system.get_active_events().is_empty())
	simulation.quest_pool.release_available_offer_map_targets()
	var spawned_events: Array = simulation.event_system.spawn_initial_population_if_ready(100)
	var event_instance = find_event_by_id(spawned_events, "smoke_over_old_tower")
	assert(event_instance != null, "Smoke Over Old Tower must find a valid paired hill/tower placement once events become eligible.")
	assert(simulation.quest_pool.assign_map_targets_to_current_offers())
	if not engage_event:
		return {"simulation": simulation, "event": event_instance}

	var available_quests: Array = simulation.quest_pool.get_available_quests()
	assert(not available_quests.is_empty())
	simulation.quest_runner.quest_definition = available_quests[0]
	var selection_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats)
	assert(selection_event != null and simulation.travel_system.is_travelling())
	var original_destination: Vector2i = simulation.travel_system.destination
	assert(simulation.world_state.set_hero_position(event_instance.target_hex), "Runtime test must place the travelling hero at the event encounter center.")
	simulation.pending_event_instance = event_instance
	assert(simulation.begin_pending_event_if_ready(100))
	assert(event_instance.encounter_hex == event_instance.target_hex)
	assert(simulation.travel_system.has_suspended_travel())
	return {
		"simulation": simulation,
		"event": event_instance,
		"original_destination": original_destination,
	}

func advance_until_event_complete(simulation, max_ticks: int) -> int:
	var ticks_used: int = 0
	while simulation.event_runner.active_event != null and ticks_used < max_ticks:
		assert(simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT, "This helper is only for non-combat continuation.")
		ticks_used += 1
		simulation.advance_event_tick(300 + ticks_used)
	assert(simulation.event_runner.active_event == null, "Temporary event must complete inside the expected runtime bound.")
	return ticks_used

func find_event_by_id(events: Array, event_id: String):
	for event_instance in events:
		if event_instance != null and event_instance.definition != null and event_instance.definition.id == event_id:
			return event_instance
	return null

func get_total_equipment_item_count(simulation) -> int:
	return simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()

func find_common_ilvl10_item(simulation):
	for item in simulation.hero_state.inventory.get_items():
		if item != null and item.item_level == 10 and item.rarity == 0:
			return item
	for item in simulation.hero_state.equipment.get_all_items():
		if item != null and item.item_level == 10 and item.rarity == 0:
			return item
	return null
