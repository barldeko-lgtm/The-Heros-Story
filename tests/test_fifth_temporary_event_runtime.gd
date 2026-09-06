extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EventDefinitionResource = preload("res://data/events/starting_region/0005_ogre_at_old_barrow.tres")

func _init() -> void:
	test_plains_placement()
	test_dexterity_attacks_at_seventy_five_percent_and_gets_reward()
	test_strength_base_starts_at_eighty_percent()
	test_strength_conservative_extra_preparation_starts_at_sixty_five_percent()
	test_constitution_base_starts_at_eighty_five_percent_and_moves_cautious()
	test_constitution_devious_extra_preparation_starts_at_seventy_percent()
	print("PASS: Ogre at Old Barrow uses partial starting HP only, DEX Brave pressure, CON Cautious movement, Devious-or-Conservative extra preparation, Experienced Ogre XP, and Green ilvl 10 reward.")
	quit()

func test_plains_placement() -> void:
	var setup: Dictionary = create_started_event_simulation(9601, false)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	var city: Vector2i = simulation.hex_map.definition.starting_city_center
	var event_hex = simulation.hex_map.get_hex(event_instance.target_hex)
	var distance: int = simulation.hex_map.get_distance_steps(city, event_instance.target_hex)
	assert(event_instance.spawn_tick == 100)
	assert(event_hex != null and event_hex.terrain_id == "plains")
	assert(distance >= 5 and distance <= 6)
	assert(not event_hex.has_tag("city"))
	assert(not event_instance.has_secondary_target())

func test_dexterity_attacks_at_seventy_five_percent_and_gets_reward() -> void:
	var setup: Dictionary = create_started_event_simulation(9602)
	var simulation = setup["simulation"]
	var event_instance = setup["event"]
	prepare_personality(simulation)
	set_combat_safe_stats(simulation, "dexterity")
	var starting_gold: int = simulation.hero_state.gold
	var starting_xp: int = simulation.hero_state.experience
	var starting_items: int = get_total_equipment_item_count(simulation)

	assert(advance_until_event_combat(simulation, 20) == 3, "DEX must attack immediately after its one-tick opening strike scene.")
	assert(simulation.hero_state.personality_axis_values["courage"] == 5)
	start_and_assert_ogre_combat(simulation, 0.75)
	simulation.advance_active_combat(1000.0)
	assert(simulation.hero_state.experience == starting_xp + 195)
	assert(advance_until_event_complete_without_combat(simulation, 10) == 1)
	assert(simulation.hero_state.gold == starting_gold, "This event grants no Gold beyond the authored equipment reward.")
	assert(get_total_equipment_item_count(simulation) == starting_items + 1, "Event combat must not add the Experienced Ogre's ordinary drop on top of the authored reward.")
	assert(find_uncommon_ilvl10_item(simulation) != null)
	assert(event_instance.outcome_id == "experienced_ogre_defeated")

func test_strength_base_starts_at_eighty_percent() -> void:
	var setup: Dictionary = create_started_event_simulation(9603)
	var simulation = setup["simulation"]
	prepare_personality(simulation)
	set_combat_safe_stats(simulation, "strength")
	assert(advance_until_event_combat(simulation, 20) == 5)
	assert(simulation.hero_state.personality_axis_values["courage"] == 0, "STR preparation must not move personality by itself.")
	start_and_assert_ogre_combat(simulation, 0.80)

func test_strength_conservative_extra_preparation_starts_at_sixty_five_percent() -> void:
	var setup: Dictionary = create_started_event_simulation(9604)
	var simulation = setup["simulation"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "curiosity", -40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "conservative"))
	set_combat_safe_stats(simulation, "strength")
	assert(advance_until_event_combat(simulation, 20) == 7)
	assert(simulation.hero_state.personality_axis_values["curiosity"] == -40, "Expressive Conservative must not reinforce itself.")
	start_and_assert_ogre_combat(simulation, 0.65)

func test_constitution_base_starts_at_eighty_five_percent_and_moves_cautious() -> void:
	var setup: Dictionary = create_started_event_simulation(9605)
	var simulation = setup["simulation"]
	prepare_personality(simulation)
	set_combat_safe_stats(simulation, "constitution")
	assert(advance_until_event_combat(simulation, 20) == 6)
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	start_and_assert_ogre_combat(simulation, 0.85)

func test_constitution_devious_extra_preparation_starts_at_seventy_percent() -> void:
	var setup: Dictionary = create_started_event_simulation(9606)
	var simulation = setup["simulation"]
	prepare_personality(simulation)
	simulation.trait_development.apply_movement(simulation.hero_state, "morality", -40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "devious"))
	set_combat_safe_stats(simulation, "constitution")
	assert(advance_until_event_combat(simulation, 20) == 8)
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	assert(simulation.hero_state.personality_axis_values["morality"] == -40, "Expressive Devious must not reinforce itself.")
	start_and_assert_ogre_combat(simulation, 0.70)

func create_started_event_simulation(seed: int, engage_event: bool = true) -> Dictionary:
	var simulation = SimulationScript.new(seed, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	simulation.event_system.clear_instances()
	simulation.event_system.set_definitions([EventDefinitionResource])
	simulation.event_system.begin_population_rotation(100)
	var spawned_events: Array = simulation.event_system.spawn_current_population_if_ready(100)
	assert(spawned_events.size() == 1, "Isolated Ogre event must find one valid plains footprint at distance 5..6.")
	var event_instance = spawned_events[0]
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

func set_combat_safe_stats(simulation, winning_attribute: String) -> void:
	simulation.hero_state.strength = 500
	simulation.hero_state.dexterity = 500
	simulation.hero_state.constitution = 500
	match winning_attribute:
		"strength": simulation.hero_state.strength = 600
		"dexterity": simulation.hero_state.dexterity = 600
		"constitution": simulation.hero_state.constitution = 600
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp

func advance_until_event_combat(simulation, max_ticks: int) -> int:
	var ticks_used: int = 0
	while simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT and ticks_used < max_ticks:
		ticks_used += 1
		simulation.advance_event_tick(200 + ticks_used)
	assert(ticks_used < max_ticks)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	return ticks_used

func start_and_assert_ogre_combat(simulation, expected_ratio: float) -> void:
	assert(simulation.event_runner.get_current_mob_definition().id == "experienced_ogre")
	var ogre_definition = simulation.event_runner.get_current_mob_definition()
	simulation.start_event_combat()
	assert(is_equal_approx(simulation.active_combat_session.mob_stats.max_hp, ogre_definition.max_hp))
	assert(is_equal_approx(simulation.active_combat_session.mob_stats.attack, ogre_definition.attack))
	assert(is_equal_approx(simulation.active_combat_session.mob_stats.armor, ogre_definition.armor))
	assert(is_equal_approx(simulation.active_combat_session.mob_stats.attack_speed, ogre_definition.attack_speed))
	assert(is_equal_approx(simulation.active_combat_session.mob_remaining_hp, ogre_definition.max_hp * expected_ratio), "Only current starting HP should be reduced; the Ogre's full combat stats must stay unchanged.")

func advance_until_event_complete_without_combat(simulation, max_ticks: int) -> int:
	var ticks_used: int = 0
	while simulation.event_runner.active_event != null and ticks_used < max_ticks:
		assert(simulation.hero_state.loop_state != simulation.hero_state.EVENT_COMBAT, "This path unexpectedly entered another combat.")
		ticks_used += 1
		simulation.advance_event_tick(400 + ticks_used)
	assert(simulation.event_runner.active_event == null)
	return ticks_used

func get_total_equipment_item_count(simulation) -> int:
	return simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()

func find_uncommon_ilvl10_item(simulation):
	for item in simulation.hero_state.inventory.get_items():
		if item != null and item.item_level == 10 and item.rarity == 1:
			return item
	for item in simulation.hero_state.equipment.get_all_items():
		if item != null and item.item_level == 10 and item.rarity == 1:
			return item
	return null
