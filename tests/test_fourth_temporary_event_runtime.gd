extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_plains_placement_at_spawn_gate()
	test_wisdom_safe_branch()
	test_wisdom_devious_branch_stays_safe()
	test_dexterity_fight_branch_gets_item_and_xp()
	test_dexterity_devious_branch_avoids_combat()
	test_dexterity_can_establish_curiosity_for_letter_search()
	test_constitution_fight_branch_gets_witness_gold()
	test_constitution_devious_curious_branch_stacks_rewards()
	print("PASS: Dead Courier uses distinct WIS safety, DEX item, CON witness reward, Devious combat avoidance, and Curious letter search.")
	quit()

func test_plains_placement_at_spawn_gate() -> void:
	var setup: Dictionary = create_started_event_simulation(9501, false)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var city: Vector2i = simulation.hex_map.definition.starting_city_center
	var event_hex = simulation.hex_map.get_hex(event_instance.target_hex)
	var distance: int = simulation.hex_map.get_distance_steps(city, event_instance.target_hex)
	assert(event_instance.spawn_tick == 100)
	assert(event_hex != null and event_hex.terrain_id == "plains")
	assert(distance >= 2 and distance <= 5)
	assert(not event_hex.has_tag("city"))
	assert(not event_hex.has_tag("road"))
	assert(not event_instance.has_secondary_target())

func test_wisdom_safe_branch() -> void:
	var setup: Dictionary = create_started_event_simulation(9502)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.hero_state.wisdom = 40
	simulation.hero_state.dexterity = 5
	simulation.hero_state.constitution = 5
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete_without_combat(simulation, 30)
	assert(ticks_used == 7, "WIS base path must take 7 total event ticks including intro/decision/check/end and never enter combat.")
	assert(simulation.hero_state.gold == starting_gold + 75)
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["courage"] == 5)
	assert(event_instance.outcome_id == "wis_case_solved")

func test_wisdom_devious_branch_stays_safe() -> void:
	var setup: Dictionary = create_started_event_simulation(9503)
	var simulation = setup["simulation"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "morality", -40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "devious"))
	simulation.hero_state.wisdom = 40
	simulation.hero_state.dexterity = 5
	simulation.hero_state.constitution = 5
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete_without_combat(simulation, 30)
	assert(ticks_used == 8, "Expressive Devious adds one interrogation scene to WIS but must still avoid combat.")
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["morality"] == -40, "Expressive Devious must not reinforce itself.")
	assert(simulation.hero_state.personality_axis_values["courage"] == 5)

func test_dexterity_fight_branch_gets_item_and_xp() -> void:
	var setup: Dictionary = create_started_event_simulation(9504)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.hero_state.dexterity = 200
	simulation.hero_state.constitution = 5
	simulation.hero_state.wisdom = 5
	simulation.hero_state.strength = 200
	simulation.refresh_combat_stats()
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience
	var starting_items: int = get_total_equipment_item_count(simulation)

	var precombat_ticks: int = advance_until_event_combat(simulation, 20)
	assert(precombat_ticks == 5)
	assert(simulation.event_runner.get_current_mob_definition().id == "bandit")
	simulation.start_event_combat()
	simulation.advance_active_combat(1000.0)
	assert(simulation.hero_state.experience == starting_xp + 90)
	var postcombat_ticks: int = advance_until_event_complete_without_combat(simulation, 20)
	assert(postcombat_ticks == 2)
	assert(simulation.hero_state.gold == starting_gold + 75)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 5)
	assert(get_total_equipment_item_count(simulation) == starting_items + 1, "DEX stash must award exactly one authored Common ilvl 5 item; event combat must not add an ordinary mob drop.")
	assert(find_common_ilvl5_item(simulation) != null)
	assert(event_instance.outcome_id == "dex_fight_case_solved")

func test_dexterity_devious_branch_avoids_combat() -> void:
	var setup: Dictionary = create_started_event_simulation(9505)
	var simulation = setup["simulation"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "morality", -40)
	simulation.hero_state.dexterity = 40
	simulation.hero_state.constitution = 5
	simulation.hero_state.wisdom = 5
	var starting_xp: int = simulation.hero_state.experience
	var starting_items: int = get_total_equipment_item_count(simulation)

	var ticks_used: int = advance_until_event_complete_without_combat(simulation, 30)
	assert(ticks_used == 8, "DEX Devious confession replaces the one-tick fight and keeps the base total duration at 8.")
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["morality"] == -40)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 5)
	assert(get_total_equipment_item_count(simulation) == starting_items + 1)

func test_dexterity_can_establish_curiosity_for_letter_search() -> void:
	var setup: Dictionary = create_started_event_simulation(9506)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "curiosity", 35)
	assert(not simulation.trait_development.has_trait(simulation.hero_state, "curious"))
	simulation.hero_state.dexterity = 200
	simulation.hero_state.constitution = 5
	simulation.hero_state.wisdom = 5
	simulation.hero_state.strength = 200
	simulation.refresh_combat_stats()
	var starting_gold: int = simulation.hero_state.gold
	var starting_items: int = get_total_equipment_item_count(simulation)

	assert(advance_until_event_combat(simulation, 20) == 5)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "curious"))
	simulation.start_event_combat()
	simulation.advance_active_combat(1000.0)
	var postcombat_ticks: int = advance_until_event_complete_without_combat(simulation, 20)
	assert(postcombat_ticks == 4, "Newly established Curious must add the same event's two-tick letter search.")
	assert(simulation.hero_state.gold == starting_gold + 125)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 40, "Expressive Curious must not reinforce itself after DEX established it.")
	assert(get_total_equipment_item_count(simulation) == starting_items + 1)
	assert(event_instance.outcome_id == "dex_fight_case_solved_letter")

func test_constitution_fight_branch_gets_witness_gold() -> void:
	var setup: Dictionary = create_started_event_simulation(9507)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.hero_state.constitution = 200
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 5
	simulation.hero_state.strength = 200
	simulation.refresh_combat_stats()
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	assert(advance_until_event_combat(simulation, 20) == 7)
	simulation.start_event_combat()
	simulation.advance_active_combat(1000.0)
	assert(simulation.hero_state.experience == starting_xp + 90)
	assert(advance_until_event_complete_without_combat(simulation, 20) == 2)
	assert(simulation.hero_state.gold == starting_gold + 100)
	assert(simulation.hero_state.personality_axis_values["morality"] == 5)
	assert(event_instance.outcome_id == "con_fight_witness_saved")

func test_constitution_devious_curious_branch_stacks_rewards() -> void:
	var setup: Dictionary = create_started_event_simulation(9508)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "morality", -40)
	simulation.trait_development.apply_movement(simulation.hero_state, "curiosity", 40)
	simulation.hero_state.constitution = 50
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 5
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience

	var ticks_used: int = advance_until_event_complete_without_combat(simulation, 30)
	assert(ticks_used == 12)
	assert(simulation.hero_state.gold == starting_gold + 150)
	assert(simulation.hero_state.experience == starting_xp)
	assert(simulation.hero_state.personality_axis_values["morality"] == -35, "CON Formative +5 moves toward Noble, but established Devious remains active by hysteresis and is not reinforced by the Expressive check.")
	assert(simulation.trait_development.has_trait(simulation.hero_state, "devious"))
	assert(simulation.hero_state.personality_axis_values["curiosity"] == 40)
	assert(event_instance.outcome_id == "con_confession_witness_saved_letter")

func create_started_event_simulation(seed: int, engage_event: bool = true) -> Dictionary:
	var simulation = SimulationScript.new(seed, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	var spawned_events: Array = simulation.event_system.spawn_initial_population_if_ready(100)
	var event_instance = find_event_by_id(spawned_events, "dead_courier")
	assert(event_instance != null, "Dead Courier must find valid non-road plains placement at distance 2..5 once the event gate opens.")
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
	return {"simulation": simulation, "event": event_instance}

func prepare_personality(simulation) -> void:
	simulation.trait_development.reset_state(simulation.hero_state)

func advance_until_event_combat(simulation, max_ticks: int) -> int:
	var ticks_used: int = 0
	while simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT and ticks_used < max_ticks:
		ticks_used += 1
		simulation.advance_event_tick(200 + ticks_used)
	assert(ticks_used < max_ticks)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	return ticks_used

func advance_until_event_complete_without_combat(simulation, max_ticks: int) -> int:
	var ticks_used: int = 0
	while simulation.event_runner.active_event != null and ticks_used < max_ticks:
		assert(simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT, "This path unexpectedly entered combat.")
		ticks_used += 1
		simulation.advance_event_tick(400 + ticks_used)
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
