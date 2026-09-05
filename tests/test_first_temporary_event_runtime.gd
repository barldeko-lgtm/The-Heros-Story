extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")

func _init() -> void:
	test_wisdom_branch()
	test_standard_dexterity_branch()
	test_brave_dexterity_branch()
	test_strength_shared_combat_branch()
	test_event_combat_death_cancels_quest()
	print("PASS: First temporary event resolves live WIS and Brave-DEX branches, rewards, personality, and route restoration.")
	quit()

func create_started_event_simulation(seed: int):
	var simulation = SimulationScript.new(seed, null, [], true)
	assert(simulation.event_system.get_active_events().size() == 1, "First slice must spawn the authored Old Clearing event.")
	var available_quests: Array = simulation.quest_pool.get_available_quests()
	assert(not available_quests.is_empty())
	simulation.quest_runner.quest_definition = available_quests[0]
	var selection_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats)
	assert(selection_event != null)
	assert(simulation.travel_system.is_travelling(), "Selected map quest must have active travel before event interruption.")
	simulation.pending_event_instance = simulation.event_system.get_active_events()[0]
	assert(simulation.begin_pending_event_if_ready(0))
	assert(simulation.event_runner.active_event != null)
	assert(simulation.travel_system.has_suspended_travel())
	return simulation

func test_wisdom_branch() -> void:
	var simulation = create_started_event_simulation(8101)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 30
	var starting_gold: int = simulation.hero_state.gold

	for tick in range(1, 9):
		simulation.advance_event_tick(tick)

	assert(simulation.event_runner.active_event == null)
	assert(simulation.event_system.get_active_events().is_empty())
	assert(simulation.hero_state.gold == starting_gold + 30)
	assert(simulation.hero_state.personality_axis_values["courage"] == -5)
	assert(simulation.hero_state.loop_state == simulation.hero_state.TRAVEL_TO_QUEST)
	assert(simulation.travel_system.is_travelling(), "Successful event must resume the interrupted quest route.")

func test_brave_dexterity_branch() -> void:
	var simulation = create_started_event_simulation(8102)
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
	assert(simulation.hero_state.personality_axis_values["courage"] == 5)

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
	assert(simulation.event_system.get_active_events().is_empty())
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
