extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_level_gate_and_city_routine_priority()
	test_relocation_from_normal_city_decision_point()
	print("PASS: Level 13 triggers real travel from Starting City to Mid-Level City only at a normal safe-city decision point.")
	quit()

func test_level_gate_and_city_routine_priority() -> void:
	var simulation = SimulationScript.new(9401, null)
	simulation.hero_state.level = 12
	assert(not simulation.should_relocate_to_mid_city(), "Level 12 must not trigger the temporary Prototype 0.2 city-relocation rule.")

	simulation.hero_state.level = 13
	assert(simulation.should_relocate_to_mid_city(), "Level 13 must enable the temporary Prototype 0.2 relocation rule while Starting City is current.")
	simulation.hero_state.loop_state = HeroState.SHOPPING
	simulation.shop_system.listings = []
	simulation.hero_state.gold = 0
	simulation.advance_shop_purchase_tick(1)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_CITY, "After normal shopping finishes at level 13, relocation must take priority over another quest or dungeon.")
	assert(simulation.hero_state.current_city_id == HeroState.STARTING_CITY_ID, "Starting City remains current until the hero physically reaches Mid-Level City.")
	assert(simulation.travel_system.destination == simulation.hex_map.definition.mid_city_center, "Relocation must use the real Mid-Level City center as its TravelSystem destination.")

	var expected_steps: int = simulation.hex_map.get_distance_steps(simulation.hex_map.definition.starting_city_center, simulation.hex_map.definition.mid_city_center)
	assert(simulation.travel_system.get_remaining_steps() == expected_steps and expected_steps > 0, "City relocation must use the authored real hex route rather than teleportation.")
	for step_index in expected_steps:
		simulation.advance_time(10.0)
		if step_index < expected_steps - 1:
			assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_CITY, "The hero must remain in relocation travel until the destination city is actually reached.")

	assert(simulation.world_state.hero_position == simulation.hex_map.definition.mid_city_center, "Relocation must physically end on the Mid-Level City center hex.")
	assert(simulation.hero_state.current_city_id == HeroState.MID_CITY_ID, "Arrival must change the hero's authoritative current-city id to Mid-Level City.")
	assert(simulation.hero_state.loop_state == HeroState.ARRIVED_IN_CITY, "Until Mid-Level City gameplay is wired, arrival must stop in the explicit arrival state instead of using Starting City quests.")
	assert(not simulation.travel_system.is_travelling(), "Arrival must clear the completed city route.")
	assert(simulation.debug_log.get_text().contains("достиг 13 уровня") and simulation.debug_log.get_text().contains("прибыл в Средний город"), "Relocation must be visible in the developer log.")

func test_relocation_from_normal_city_decision_point() -> void:
	var simulation = SimulationScript.new(9402, null)
	simulation.hero_state.level = 13
	simulation.hero_state.loop_state = HeroState.CHOOSING_QUEST
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_CITY, "A level-13 hero who reaches an ordinary safe-city decision point must relocate before selecting another Starting City quest.")
	assert(simulation.hero_state.active_quest == null, "Relocation must not select a new Starting City quest on the same decision tick.")
