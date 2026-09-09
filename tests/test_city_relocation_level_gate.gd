extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_level_gate_and_city_routine_priority()
	test_relocation_from_normal_city_decision_point()
	print("PASS: Level 13 triggers real travel from Starting City to Mid-Level City only at a normal safe-city decision point.")
	quit()

func test_level_gate_and_city_routine_priority() -> void:
	var simulation = SimulationScript.new(9401, null)
	assert(HeroState.STARTING_CITY_NAME == "Дорнвальд" and HeroState.MID_CITY_NAME == "Арден", "The two Prototype 0.2 cities must use their approved authored names.")
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
	assert(simulation.hero_state.loop_state == HeroState.ARRIVED_IN_CITY, "The arrival tick must stop before the hero heads to Arden's guild.")
	assert(not simulation.travel_system.is_travelling(), "Arrival must clear the completed city route.")
	assert(simulation.debug_log.get_text().contains("Дорнвальд") and simulation.debug_log.get_text().contains("Арден"), "Relocation must use the authored city names in the developer log.")
	assert(simulation.diary.get_text().contains("Арден") and simulation.diary.entries.size() == 1, "Physical arrival in Arden must create exactly one arrival Diary entry on that same world tick.")

	var arrival_tick: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == arrival_tick + 1, "Heading to the guild must happen on the tick after Arden arrival.")
	assert(simulation.hero_state.loop_state == HeroState.VISITING_GUILD, "After the arrival Diary tick the hero must head to Arden's guild.")
	assert(simulation.hero_state.active_quest == null, "Arden must not reuse Dornwald's quest board before its own city context is connected.")
	assert(simulation.diary.entries.size() == 1, "Heading to the guild must not duplicate the one-time Arden arrival Diary entry.")
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.VISITING_GUILD and simulation.hero_state.active_quest == null, "Until Arden's own quest context is connected, the hero must wait at its guild rather than selecting a Dornwald quest.")
	assert(simulation.diary.entries.size() == 1, "Waiting at Arden's guild must keep the arrival Diary passage one-time only.")

func test_relocation_from_normal_city_decision_point() -> void:
	var simulation = SimulationScript.new(9402, null)
	simulation.hero_state.level = 13
	simulation.hero_state.loop_state = HeroState.CHOOSING_QUEST
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_CITY, "A level-13 hero who reaches an ordinary safe-city decision point must relocate before selecting another Starting City quest.")
	assert(simulation.hero_state.active_quest == null, "Relocation must not select a new Starting City quest on the same decision tick.")
