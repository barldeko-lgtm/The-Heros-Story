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
	assert(simulation.quest_pool.quest_templates.size() == 26, "Physical arrival in Arden must switch the active local QuestPool to all 26 Arden templates.")
	assert(simulation.quest_pool.placement_region_id == simulation.hex_map.MID_REGION_ID and simulation.quest_pool.placement_distance_origin == simulation.hex_map.definition.mid_city_center, "Arden's active quest board must use the Mid Region and Arden center as its placement context.")
	assert(simulation.quest_runner.city_center == simulation.hex_map.definition.mid_city_center, "Ordinary quests accepted in Arden must return through Arden's real city center.")
	assert(simulation.quest_pool.get_available_quests().size() == 12, "Arrival in Arden must expose the current full 4/4/4 local board.")
	for arden_offer in simulation.quest_pool.get_available_quests():
		assert(arden_offer.has_map_target(), "Every Arden board offer must already own a real Mid Region target.")
		assert(simulation.hex_map.get_hex(arden_offer.target_hex).region_id == simulation.hex_map.MID_REGION_ID, "Arden must never expose a Dornwald-region target through its local board.")

	var arrival_tick: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == arrival_tick + 1, "Heading to the guild must happen on the tick after Arden arrival.")
	assert(simulation.hero_state.loop_state == HeroState.VISITING_GUILD, "After the arrival Diary tick the hero must head to Arden's guild.")
	assert(simulation.hero_state.active_quest == null, "The guild-visit tick must remain separate from taking the first Arden quest.")
	assert(simulation.diary.entries.size() == 1, "Heading to the guild must not duplicate the one-time Arden arrival Diary entry.")

	# This fixture changes only the level gate, so give it a realistic-enough combat
	# profile before asking it to exercise Arden's 300+ Power ordinary board.
	simulation.hero_state.strength = 70
	simulation.hero_state.dexterity = 30
	simulation.hero_state.constitution = 45
	simulation.hero_state.wisdom = 30
	simulation.refresh_combat_stats()
	assert(simulation.get_hero_power() > 350.0 and simulation.get_hero_power() < 550.0, "The Arden selection fixture must sit inside the transition-board Power window.")
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST and simulation.hero_state.active_quest != null, "The tick after visiting Arden's guild must autonomously accept a suitable local Arden quest.")
	assert(simulation.hero_state.active_quest.mob_definition.get_power() >= 300.0, "The first Arden quest must come from the authored 300+ Power Mid Region roster rather than Dornwald content.")
	assert(simulation.hex_map.get_hex(simulation.hero_state.active_quest.target_hex).region_id == simulation.hex_map.MID_REGION_ID, "The selected Arden quest must travel to a real target in Mid Region.")

	# Make combat deterministic/safe after selection, then prove the complete ordinary
	# quest route returns to Arden rather than the formerly hard-coded Starting City.
	simulation.hero_state.strength = 220
	simulation.hero_state.dexterity = 120
	simulation.hero_state.constitution = 220
	simulation.hero_state.wisdom = 80
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	simulation.set_time_scale(100.0)
	var guard: int = 0
	while simulation.hero_state.loop_state != HeroState.VISITING_MARKET and simulation.hero_state.loop_state != HeroState.DEAD_RESPAWNING and guard < 5000:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 5000 and simulation.hero_state.loop_state == HeroState.VISITING_MARKET, "A safe Arden quest must complete and reach the normal post-turn-in market state during the integration test.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.mid_city_center, "A completed Arden ordinary quest must physically return to Arden, never Dornwald.")
	assert(simulation.hero_state.current_city_id == HeroState.MID_CITY_ID, "Completing an Arden quest must preserve Arden as the authoritative current city.")

func test_relocation_from_normal_city_decision_point() -> void:
	var simulation = SimulationScript.new(9402, null)
	simulation.hero_state.level = 13
	simulation.hero_state.loop_state = HeroState.CHOOSING_QUEST
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_CITY, "A level-13 hero who reaches an ordinary safe-city decision point must relocate before selecting another Starting City quest.")
	assert(simulation.hero_state.active_quest == null, "Relocation must not select a new Starting City quest on the same decision tick.")
