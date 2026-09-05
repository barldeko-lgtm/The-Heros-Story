extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")

func _init() -> void:
	test_event_interrupts_outbound_dungeon_travel_and_resumes()
	test_event_death_on_outbound_trip_cancels_trip_without_dungeon_failure()
	print("PASS: Temporary events can interrupt outbound dungeon travel, resume the dungeon route, and road-event death does not count as a dungeon failure.")
	quit()

func test_event_interrupts_outbound_dungeon_travel_and_resumes() -> void:
	var simulation = create_clean_event_simulation(9401)
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	assert(dungeon.discover("test"))
	assert(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, simulation.get_hero_power()))
	var original_destination: Vector2i = dungeon.target_hex
	assert(spawn_old_clearing_on_active_route(simulation), "Test must place one event on the live route to the dungeon.")
	prepare_wisdom_branch(simulation)

	advance_dungeon_travel_until_event(simulation, 30)
	assert(simulation.hero_state.loop_state == HeroState.EVENT_ACTIVE)
	assert(simulation.event_runner.get_interrupted_loop_state() == HeroState.TRAVEL_TO_DUNGEON)
	assert(simulation.travel_system.has_suspended_travel())
	assert(simulation.travel_system.suspended_destination == original_destination)

	resolve_old_clearing_wisdom(simulation, 200)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON)
	assert(simulation.dungeon_runner.active_dungeon == dungeon)
	assert(simulation.travel_system.is_travelling())
	assert(simulation.travel_system.destination == original_destination)

	var guard := 0
	while simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON and guard < 30:
		simulation.advance_dungeon_travel_tick(300 + guard)
		guard += 1
	assert(guard < 30)
	assert(simulation.hero_state.loop_state == HeroState.DOING_DUNGEON)
	assert(simulation.world_state.hero_position == dungeon.target_hex)

func test_event_death_on_outbound_trip_cancels_trip_without_dungeon_failure() -> void:
	var simulation = create_clean_event_simulation(9402)
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	assert(dungeon.discover("test"))
	assert(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, simulation.get_hero_power()))
	assert(spawn_old_clearing_on_active_route(simulation))
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 30
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 5

	advance_dungeon_travel_until_event(simulation, 30)
	assert(simulation.event_runner.get_interrupted_loop_state() == HeroState.TRAVEL_TO_DUNGEON)
	for tick in range(1, 4):
		simulation.advance_event_tick(600 + tick)
	assert(simulation.hero_state.loop_state == HeroState.EVENT_COMBAT)
	var fought_mob = simulation.event_runner.get_current_mob_definition()
	assert(fought_mob != null)
	var loss = CombatResultScript.new(false, 0.0, 10.0, 1.0, [])
	simulation.complete_event_combat(fought_mob, loss, 604)

	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING)
	assert(simulation.event_runner.owns_respawn_state())
	assert(simulation.dungeon_runner.active_dungeon == null, "Road-event death must abandon the current dungeon trip runtime state.")
	assert(dungeon.failed_attempt_count == 0, "Dying before entering the dungeon must not create a dungeon failure/retry penalty.")
	assert(not dungeon.completed)
	assert(dungeon.has_map_target(), "An unentered dungeon must remain in the world after a road-event death.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.starting_city_center)

func create_clean_event_simulation(seed: int):
	var simulation = SimulationScript.new(seed, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	return simulation

func spawn_old_clearing_on_active_route(simulation) -> bool:
	var definition = simulation.event_system.get_definition_by_id("old_clearing_ambush")
	assert(definition != null)
	var route: Array[Vector2i] = simulation.travel_system.get_route()
	if route.size() < 3:
		return false
	var city_center: Vector2i = simulation.hex_map.definition.starting_city_center
	for route_index in range(1, route.size() - 1):
		if simulation.event_system.try_spawn_definition_at(definition, route[route_index], city_center, 100):
			return true
	return false

func prepare_wisdom_branch(simulation) -> void:
	simulation.trait_development.reset_state(simulation.hero_state)
	simulation.hero_state.strength = 5
	simulation.hero_state.dexterity = 5
	simulation.hero_state.wisdom = 30

func resolve_old_clearing_wisdom(simulation, first_tick: int) -> void:
	for offset in range(8):
		simulation.advance_event_tick(first_tick + offset)
	assert(simulation.event_runner.active_event == null)

func advance_dungeon_travel_until_event(simulation, max_ticks: int) -> void:
	var ticks := 0
	while simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON and ticks < max_ticks:
		simulation.advance_dungeon_travel_tick(100 + ticks)
		ticks += 1
	assert(ticks < max_ticks, "Dungeon outbound travel must encounter the placed event before reaching the dungeon.")
