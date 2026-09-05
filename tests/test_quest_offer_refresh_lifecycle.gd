extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(8080, null)
	simulation.hero_state.hero_name = "Алексей"

	var initial_offers: Array = find_suitable_current_board(simulation)
	assert(not initial_offers.is_empty(), "The tavern must start with at least one current quest offer.")

	simulation.advance_time(10.0)
	var accepted_offer = simulation.hero_state.active_quest
	assert(accepted_offer != null, "Autonomous selection must accept one current tavern offer.")
	var accepted_index := initial_offers.find(accepted_offer)
	assert(accepted_index >= 0, "The accepted quest must be one of the offers currently in the tavern.")
	assert(simulation.quest_pool.get_available_quests().size() == initial_offers.size() - 1, "Taking a quest must leave its board slot empty until the next global rotation.")
	assert(not simulation.quest_pool.get_available_quests().has(accepted_offer), "The active quest must no longer count as an available board offer.")
	assert(accepted_offer.has_map_target(), "Accepting a quest must keep its existing board target visible on the map while it is being performed.")
	var accepted_target: Vector2i = accepted_offer.target_hex
	var accepted_activity_id: String = accepted_offer.map_activity_id
	assert(simulation.world_state.get_activity_id_at_hex(accepted_target) == accepted_activity_id, "Accepted quest target must remain reserved during quest execution.")
	var city_center: Vector2i = simulation.hex_map.definition.starting_city_center
	var outward_route: Array[Vector2i] = simulation.hex_map.find_path(city_center, accepted_target)
	assert(accepted_offer.map_distance_steps == outward_route.size() - 1, "QuestOffer map distance must equal the real route length from its city center.")
	assert(simulation.quest_runner.travel_ticks_remaining == accepted_offer.map_distance_steps, "Selected quest travel ticks must come from the real map route length.")
	assert(simulation.world_state.hero_position == city_center, "Selecting a quest must not move the hero before the first travel world tick.")
	for route_index in range(1, outward_route.size()):
		simulation.advance_time(10.0)
		assert(simulation.world_state.hero_position == outward_route[route_index], "Each outward travel tick must move the hero to the next real route hex.")
	assert(simulation.hero_state.loop_state == HeroState.DOING_QUEST, "Reaching the real quest target must start quest execution.")
	assert(simulation.world_state.hero_position == accepted_target, "Hero must physically stand on the quest target while performing it.")

	simulation.set_time_scale(100.0)
	var guard := 0
	while simulation.hero_state.loop_state != HeroState.RETURNING_TO_CITY and guard < 2000:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 2000, "The selected safe quest must finish its objective during the test.")
	assert(not accepted_offer.has_map_target(), "Finishing the quest objective must remove its marker before the return trip starts.")
	assert(simulation.world_state.get_activity_id_at_hex(accepted_target) != accepted_activity_id, "Finishing the quest objective must free its target hex before turn-in.")
	assert(simulation.world_state.hero_position == accepted_target, "Completing the objective must begin the return route from the real quest target.")

	simulation.set_time_scale(1.0)
	var return_route: Array[Vector2i] = simulation.hex_map.find_path(accepted_target, city_center)
	assert(simulation.quest_runner.travel_ticks_remaining == return_route.size() - 1, "Return travel ticks must equal the real route length back to the city center.")
	for route_index in range(1, return_route.size()):
		simulation.advance_time(10.0)
		assert(simulation.world_state.hero_position == return_route[route_index], "Each return travel tick must move the hero to the next real route hex.")
	assert(simulation.hero_state.loop_state == HeroState.TURNING_IN_QUEST, "Arriving at the city center must enter quest turn-in.")
	assert(simulation.world_state.hero_position == city_center, "Hero must physically return to the city center before turn-in.")

	while simulation.hero_state.gold == 0 and guard < 4000:
		simulation.advance_time(10.0)
		guard += 1
	assert(guard < 4000, "The selected safe quest must be turned in during the test.")
	var offers_after_turn_in: Array = simulation.quest_pool.get_available_quests()
	assert(not offers_after_turn_in.has(accepted_offer), "Turning in a quest must not regenerate its old runtime offer.")
	assert(not accepted_offer.has_map_target(), "The completed QuestOffer must remain absent from the map after turn-in.")
	assert(simulation.world_state.get_activity_id_at_hex(accepted_target) != accepted_activity_id, "The completed quest's old map reservation must remain released after turn-in.")
	var cooldown_until_tick: int = simulation.quest_pool.get_template_cooldown_until_tick(accepted_offer.id)
	assert(cooldown_until_tick == simulation.world_clock.world_tick + 50, "Completed quest template must enter its 50-tick availability cooldown.")
	assert(simulation.world_state.hero_position == city_center, "Completing the map-backed quest loop must leave the hero in Starting City.")

	print("PASS: Taking a quest creates a board vacancy, preserves its active map target, and completion starts template cooldown without immediate refill.")
	quit()

func find_suitable_current_board(simulation) -> Array:
	for _roll in 10:
		var offers: Array = simulation.quest_pool.get_available_quests()
		var selection: Dictionary = simulation.quest_evaluator.select_quest(offers, simulation.get_hero_power(), simulation.hero_state.traits)
		if selection.get("selected_quest") != null:
			return offers
		assert(simulation.quest_pool.refresh_board(simulation.world_clock.world_tick), "Test setup must be able to reroll the current board until a suitable offer exists.")
	return []
