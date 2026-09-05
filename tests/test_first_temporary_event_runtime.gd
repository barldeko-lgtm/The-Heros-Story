extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")
const DefaultQuest = preload("res://data/quests/0001_goblin_road_problem.tres")

func _init() -> void:
	test_event_spawn_gate()
	test_wisdom_branch()
	test_standard_dexterity_branch()
	test_brave_dexterity_branch()
	test_strength_shared_combat_branch()
	test_event_combat_death_cancels_quest()
	print("PASS: First temporary event resolves live WIS and Brave-DEX branches, rewards, personality, and route restoration.")
	quit()

func test_event_spawn_gate() -> void:
	var simulation = SimulationScript.new(8199, DefaultQuest, [], true)
	assert(simulation.event_system.get_active_events().is_empty(), "Temporary events must not exist on the map at game start.")
	simulation.on_world_tick_completed(99)
	assert(simulation.event_system.get_active_events().is_empty(), "Temporary events must remain unavailable through world tick 99.")
	simulation.on_world_tick_completed(100)
	var active_events: Array = simulation.event_system.get_active_events()
	var old_clearing = find_event_by_id(active_events, "old_clearing_ambush")
	assert(old_clearing != null, "When a valid footprint is free, Old Clearing must spawn once the temporary-event population opens on world tick 100.")
	assert(old_clearing.spawn_tick == 100, "The first event instance must record world tick 100 as its spawn tick.")

func create_started_event_simulation(seed: int):
	var simulation = SimulationScript.new(seed, null, [], true)
	assert(simulation.event_system.get_active_events().is_empty(), "Temporary events must not spawn before the global world-tick gate.")
	simulation.quest_pool.release_available_offer_map_targets()
	var spawned_events: Array = simulation.event_system.spawn_initial_population_if_ready(100)
	var old_clearing = find_event_by_id(spawned_events, "old_clearing_ambush")
	assert(old_clearing != null, "First slice must spawn the authored Old Clearing event once world tick 100 is eligible.")
	assert(simulation.quest_pool.assign_map_targets_to_current_offers(), "Quest offers must be placeable around the newly spawned event footprint.")
	var available_quests: Array = simulation.quest_pool.get_available_quests()
	assert(not available_quests.is_empty())
	simulation.quest_runner.quest_definition = available_quests[0]
	var selection_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats)
	assert(selection_event != null)
	assert(simulation.travel_system.is_travelling(), "Selected map quest must have active travel before event interruption.")
	simulation.pending_event_instance = old_clearing
	assert(simulation.begin_pending_event_if_ready(100))
	assert(simulation.event_runner.active_event != null)
	assert(simulation.travel_system.has_suspended_travel())
	return simulation

func test_wisdom_branch() -> void:
	var simulation = create_started_event_simulation(8101)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 30
	var starting_gold: int = simulation.hero_state.gold

	for tick in range(1, 9):
		simulation.advance_event_tick(tick)

	assert(simulation.event_runner.active_event == null)
	assert(find_event_by_id(simulation.event_system.get_active_events(), "old_clearing_ambush") == null)
	assert(simulation.hero_state.gold == starting_gold + 30)
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)
	assert(simulation.travel_system.is_travelling(), "Successful event must resume the interrupted quest route.")

func test_brave_dexterity_branch() -> void:
	var simulation = create_started_event_simulation(8102)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 30
	simulation.hero_state.wisdom = 5
	simulation.trait_development.apply_movement(simulation.hero_state, "courage", 40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "brave"))
	var starting_gold: int = simulation.hero_state.gold
	var starting_item_count: int = simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()

	for tick in range(1, 8):
		simulation.advance_event_tick(tick)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	assert(simulation.event_runner.get_current_mob_definition() != null)

	var combat_result = CombatResultScript.new(true, simulation.combat_stats.max_hp, 0.0, 1.0, [])
	var combat_resolution: Dictionary = simulation.event_runner.complete_combat(simulation.hero_state, simulation.combat_stats, combat_result)
	assert(combat_resolution["type"] == "combat_won")
	simulation.advance_event_tick(9)

	assert(simulation.event_runner.active_event == null)
	assert(simulation.hero_state.gold == starting_gold + 15)
	assert(simulation.hero_state.personality_axis_values["morality"] == 5)
	assert(simulation.hero_state.personality_axis_values["courage"] == 40, "Expressive Brave branch must not farm more Brave.")
	var ending_item_count: int = simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()
	assert(ending_item_count == starting_item_count + 1)
	var rewarded_item = find_new_green_ilvl10_item(simulation)
	assert(rewarded_item != null, "Brave DEX finish must route one Green ilvl 10 item through normal equipment/inventory handling.")
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)
	assert(simulation.travel_system.is_travelling())

func test_standard_dexterity_branch() -> void:
	var simulation = create_started_event_simulation(8103)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 30
	simulation.hero_state.wisdom = 5
	var starting_gold: int = simulation.hero_state.gold
	var starting_item_count: int = simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()

	for tick in range(1, 8):
		simulation.advance_event_tick(tick)

	assert(simulation.event_runner.active_event == null)
	assert(simulation.hero_state.gold == starting_gold + 15)
	assert(simulation.hero_state.personality_axis_values["morality"] == 5)
	assert(not simulation.trait_development.has_trait(simulation.hero_state, "brave"))
	var ending_item_count: int = simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()
	assert(ending_item_count == starting_item_count, "Neutral/non-Brave DEX fallback must not grant the bonus equipment reward.")
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)

func test_strength_shared_combat_branch() -> void:
	var simulation = create_started_event_simulation(8104)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.trait_development.apply_movement(simulation.hero_state, "courage", 35)
	assert(not simulation.trait_development.has_trait(simulation.hero_state, "brave"), "Courage +35 must still be neutral before the formative event choice.")
	simulation.hero_state.strength = 200
	simulation.hero_state.dexterity = 5
	simulation.hero_state.constitution = 100
	simulation.hero_state.wisdom = 5
	simulation.refresh_combat_stats()
	var starting_gold: int = simulation.hero_state.gold
	var starting_item_count: int = simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()

	for tick in range(1, 4):
		simulation.advance_event_tick(tick)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	assert(simulation.hero_state.personality_axis_values["courage"] == 40)
	assert(simulation.trait_development.has_trait(simulation.hero_state, "brave"), "The event's +5 Courage movement must establish Brave when it crosses +40.")

	simulation.start_event_combat()
	assert(simulation.active_combat_session != null)
	assert(simulation.active_combat_context == simulation.COMBAT_CONTEXT_EVENT)
	simulation.advance_active_combat(1000.0)
	assert(simulation.active_combat_session == null)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_ACTIVE)
	simulation.advance_event_tick(5)

	assert(simulation.event_runner.active_event == null)
	assert(simulation.hero_state.gold == starting_gold + 20)
	var ending_item_count: int = simulation.hero_state.inventory.get_items().size() + simulation.hero_state.equipment.get_all_items().size()
	assert(ending_item_count == starting_item_count, "STR event combat must not roll the ordinary mob equipment-drop path.")
	assert(simulation.travel_system.is_travelling())

func test_event_combat_death_cancels_quest() -> void:
	var simulation = create_started_event_simulation(8105)
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 30
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 5
	for tick in range(1, 4):
		simulation.advance_event_tick(tick)
	assert(simulation.hero_state.loop_state == simulation.hero_state.EVENT_COMBAT)
	var fought_mob = simulation.event_runner.get_current_mob_definition()
	var loss = CombatResultScript.new(false, 0.0, 10.0, 1.0, [])
	simulation.complete_event_combat(fought_mob, loss, 4)

	assert(simulation.hero_state.loop_state == simulation.hero_state.DEAD_RESPAWNING)
	assert(simulation.hero_state.active_quest == null, "Event death must cancel the interrupted ordinary quest.")
	assert(find_event_by_id(simulation.event_system.get_active_events(), "old_clearing_ambush") == null)
	assert(simulation.event_runner.owns_respawn_state())
	assert(simulation.hero_state.personality_axis_values["courage"] == 5, "Formative Brave movement must survive later combat failure.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.starting_city_center)
	assert(simulation.use_instant_resurrection(), "Divine instant resurrection must route through EventRunner when the event owns death.")
	assert(simulation.hero_state.loop_state == simulation.hero_state.RECOVERING_IN_CITY)

func find_new_green_ilvl10_item(simulation):
	for item in simulation.hero_state.inventory.get_items():
		if item != null and item.item_level == 10 and item.rarity == 1:
			return item
	for item in simulation.hero_state.equipment.get_all_items():
		if item != null and item.item_level == 10 and item.rarity == 1:
			return item
	return null

func find_event_by_id(events: Array, event_id: String):
	for event_instance in events:
		if event_instance != null and event_instance.definition != null and event_instance.definition.id == event_id:
			return event_instance
	return null
