extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	test_discovery_does_not_interrupt_current_quest()
	test_known_dungeon_starts_after_city_routine()
	test_full_quest_to_dungeon_priority_flow()
	print("PASS: Discovering a dungeon does not interrupt the current quest, and the hero travels to it only after the post-quest city routine.")
	quit()

func test_discovery_does_not_interrupt_current_quest() -> void:
	var simulation = SimulationScript.new(8201, null)
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST, "The autonomous hero must already be committed to the selected quest before Vision is tested.")
	var active_quest_before = simulation.hero_state.active_quest
	var travel_destination_before: Vector2i = simulation.travel_system.destination
	assert(active_quest_before != null, "The current quest must exist before dungeon discovery.")
	assert(simulation.use_divine_vision(), "Vision must reveal the current unknown Starting Region dungeon.")
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST, "Dungeon discovery must not interrupt the hero's current quest travel.")
	assert(simulation.hero_state.active_quest == active_quest_before, "Dungeon discovery must not replace or cancel the current quest.")
	assert(simulation.travel_system.destination == travel_destination_before, "Dungeon discovery must not replace the current quest route.")

func test_known_dungeon_starts_after_city_routine() -> void:
	var simulation = SimulationScript.new(8202, null)
	equip_test_belt(simulation)
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	assert(simulation.use_divine_vision(), "The post-city decision test requires a known dungeon.")
	assert(dungeon.discovered, "Vision must make the dungeon known before the city routine ends.")

	# This slice starts at the safe-city post-quest phases. The real quest loop already owns
	# turn-in -> market -> shopping; here we protect only the new decision boundary after them.
	simulation.hero_state.active_quest = null
	simulation.hero_state.loop_state = HeroState.VISITING_MARKET
	simulation.hero_state.gold = 100000
	var market_result: Dictionary = simulation.advance_market_sale_tick(1)
	assert(simulation.hero_state.loop_state == HeroState.SHOPPING, "The hero must still perform the market phase before considering the dungeon.")
	assert(market_result.has("sold_count"), "Market phase must complete through the normal sale system.")

	var shopping_ticks: int = 0
	while simulation.hero_state.loop_state == HeroState.SHOPPING and shopping_ticks < 30:
		simulation.advance_shop_purchase_tick(2 + shopping_ticks)
		shopping_ticks += 1
	assert(shopping_ticks > 0, "The normal shopping phase must be evaluated before dungeon travel begins.")
	assert(simulation.hero_state.loop_state == HeroState.PREPARING_DUNGEON, "A known ready dungeon with missing potions must schedule one dedicated potion-purchase tick after equipment shopping.")
	var preparation_tick_before: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == preparation_tick_before + 1, "Dungeon potion purchasing must consume exactly one world tick after equipment shopping.")
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON, "A known dungeon must take priority over selecting another ordinary quest after its separate potion-purchase tick.")
	assert(simulation.dungeon_runner.active_dungeon == dungeon, "DungeonRunner must own the selected known dungeon expedition target.")
	assert(simulation.travel_system.destination == dungeon.target_hex, "Dungeon travel must use the real dungeon map hex as its destination.")
	assert(simulation.hero_state.active_quest == null, "Starting dungeon travel must not create or select another ordinary quest.")

	var expected_steps: int = simulation.hex_map.get_distance_steps(simulation.world_state.hero_position, dungeon.target_hex)
	assert(expected_steps >= 1, "The spawned dungeon must require real map travel from the city.")
	for _step in expected_steps:
		simulation.advance_time(10.0)
	assert(simulation.world_state.hero_position == dungeon.target_hex, "Dungeon travel must physically move the hero to the dungeon hex.")
	assert(simulation.hero_state.loop_state == HeroState.DOING_DUNGEON, "Arrival at the dungeon must make the first encounter combat-ready without an extra world-tick delay.")

func test_full_quest_to_dungeon_priority_flow() -> void:
	var simulation = SimulationScript.new(8203, null)
	equip_test_belt(simulation)
	simulation.hero_state.gold = 100
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST, "Full-flow test must begin with a normal autonomous quest already selected.")
	var original_quest = simulation.hero_state.active_quest
	assert(original_quest != null, "Full-flow test requires a real selected quest.")
	assert(simulation.use_divine_vision(), "Full-flow test must discover the dungeon while the quest is already active.")

	var saw_market: bool = false
	var saw_shopping: bool = false
	var saw_potion_preparation: bool = false
	var reached_dungeon_priority: bool = false
	for _step in 1200:
		simulation.advance_time(10.0)
		if simulation.hero_state.loop_state == HeroState.VISITING_MARKET:
			saw_market = true
		elif simulation.hero_state.loop_state == HeroState.SHOPPING:
			saw_shopping = true
		elif simulation.hero_state.loop_state == HeroState.PREPARING_DUNGEON:
			saw_potion_preparation = true
		elif simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON or simulation.hero_state.loop_state == HeroState.AT_DUNGEON_ENTRANCE:
			reached_dungeon_priority = true
			break
	assert(saw_market, "The hero must turn in the current quest and reach the normal market phase before changing activity priority.")
	assert(saw_shopping, "The hero must evaluate the normal shopping phase before changing activity priority.")
	assert(saw_potion_preparation, "A full-flow dungeon attempt that needs a purchased potion must spend one dedicated preparation world tick before travel.")
	assert(reached_dungeon_priority, "After the current quest and city routine, the known dungeon must replace another ordinary quest as the next activity.")
	assert(simulation.hero_state.active_quest == null, "The completed ordinary quest must be cleared before dungeon travel begins.")
	assert(simulation.dungeon_runner.active_dungeon != null, "DungeonRunner must own the expedition target after the full post-quest transition.")

func equip_test_belt(simulation) -> void:
	var belt_definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var rng := RandomNumberGenerator.new()
	rng.seed = 8200
	var belt = simulation.item_generator.generate(belt_definition, 10, rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
