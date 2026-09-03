extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_full_three_fights_and_boss_sequence()
	test_dungeon_death_and_instant_resurrection()
	print("PASS: DungeonRunner executes 3 ordinary fights, boss completion, real return-to-city travel, and dungeon death/resurrection through shared combat.")
	quit()

func prepare_dungeon_at_entrance(simulation):
	var belt_definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var belt_rng := RandomNumberGenerator.new()
	belt_rng.seed = 8100
	var belt = simulation.item_generator.generate(belt_definition, 10, belt_rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.hero_state.inventory.add_healing_potion(10)
	simulation.hero_state.prepared_healing_potion_levels = [10]
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	if not dungeon.discovered:
		dungeon.discover("test")
	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Test hero must be placeable on the real dungeon hex.")
	assert(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, simulation.get_hero_power()), "Known uncompleted dungeon must allow the current temporary first attempt.")
	var travel_result: Dictionary = simulation.dungeon_runner.advance(simulation.hero_state)
	assert(bool(travel_result.get("arrived", false)), "Starting on the dungeon hex must resolve dungeon travel as already arrived.")
	assert(simulation.hero_state.loop_state == HeroState.AT_DUNGEON_ENTRANCE, "Arrival must stop at the dungeon entrance before the expedition begins.")
	assert(simulation.dungeon_runner.enter(simulation.hero_state), "The hero must be able to enter the known dungeon from its entrance.")
	assert(simulation.hero_state.loop_state == HeroState.DOING_DUNGEON, "Entering the dungeon must make the first encounter combat-ready.")
	return dungeon

func finish_current_dungeon_fight(simulation) -> void:
	assert(simulation.hero_state.loop_state == HeroState.DOING_DUNGEON, "Dungeon combat can start only from the combat-ready dungeon state.")
	simulation.start_dungeon_combat()
	assert(simulation.active_combat_session != null, "Dungeon combat must use the shared live CombatSession.")
	assert(is_equal_approx(simulation.active_combat_session.hero_remaining_hp, simulation.hero_state.current_hp), "Each dungeon fight must start from the hero's carried current HP, not free full HP.")
	simulation.advance_active_combat(1000000.0)
	assert(simulation.active_combat_session == null, "Finished dungeon combat must clear the live CombatSession.")

func consume_between_fight_tick(simulation, expect_potion_healing: bool) -> void:
	assert(simulation.hero_state.loop_state == HeroState.DUNGEON_BETWEEN_FIGHTS, "A won ordinary dungeon fight must enter the one-tick preparation state.")
	assert(simulation.dungeon_runner.between_fight_ticks_remaining == 1, "Exactly one world tick must be reserved between dungeon fights.")
	var hp_before_tick: float = simulation.hero_state.current_hp
	var potion_count_before: int = simulation.hero_state.inventory.get_total_healing_potion_count()
	var tick_before: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == tick_before + 1, "Between-fight preparation must consume exactly one world tick.")
	if expect_potion_healing:
		assert(simulation.hero_state.current_hp > hp_before_tick, "A useful prepared healing potion must restore HP during the one between-fight tick.")
		assert(simulation.hero_state.inventory.get_total_healing_potion_count() == potion_count_before - 1, "A consumed dungeon potion must leave Inventory.")
	else:
		assert(is_equal_approx(simulation.hero_state.current_hp, hp_before_tick), "Without a useful prepared potion the between-fight tick must not create free healing.")
	assert(simulation.hero_state.loop_state == HeroState.DOING_DUNGEON, "After the one preparation tick the next authored encounter must become combat-ready.")

func test_full_three_fights_and_boss_sequence() -> void:
	var simulation = SimulationScript.new(8101, null)
	# Large CON keeps the deterministic integration test alive; modest STR still lets real combat take place.
	simulation.hero_state.strength = 20
	simulation.hero_state.dexterity = 10
	simulation.hero_state.constitution = 200
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	var dungeon = prepare_dungeon_at_entrance(simulation)
	var starting_gold: int = simulation.hero_state.gold
	var starting_inventory_count: int = simulation.hero_state.inventory.get_items().size()
	var starting_equipment_count: int = simulation.hero_state.equipment.get_all_items().size()
	var starting_owned_equipment_count: int = starting_inventory_count + starting_equipment_count
	var dungeon_hex: Vector2i = dungeon.target_hex

	for ordinary_index in range(3):
		assert(simulation.dungeon_runner.get_current_mob_definition().id == "mine_troglodyte", "All three ordinary encounters must use the same Mine Troglodyte definition.")
		finish_current_dungeon_fight(simulation)
		assert(simulation.hero_state.loop_state == HeroState.DUNGEON_BETWEEN_FIGHTS, "Each ordinary victory must pause before the next fight.")
		assert(simulation.dungeon_runner.ordinary_encounters_completed == ordinary_index + 1, "DungeonRunner must advance exactly one authored ordinary encounter per victory.")
		if ordinary_index == 0:
			# Force exactly one efficient ilvl 10 potion use to protect the new dungeon-healing integration.
			simulation.hero_state.current_hp = simulation.combat_stats.max_hp - 100.0
		consume_between_fight_tick(simulation, ordinary_index == 0)

	assert(simulation.dungeon_runner.current_encounter_is_boss(), "After three ordinary encounters the next and only encounter must be the boss.")
	assert(simulation.dungeon_runner.get_current_mob_definition().id == "deep_devourer", "The final encounter must use the Deep Devourer boss definition.")
	finish_current_dungeon_fight(simulation)
	assert(simulation.hero_state.loop_state == HeroState.DUNGEON_RETURNING_TO_CITY, "Boss victory must immediately start the real return route to the city.")
	assert(dungeon.completed, "The runtime dungeon instance must remember successful completion.")
	assert(simulation.dungeon_runner.boss_defeated, "DungeonRunner must record the unique boss as defeated.")
	assert(simulation.hero_state.experience == 635, "Three 150-XP troglodytes plus the 185-XP boss must grant 635 total combat XP.")
	assert(simulation.hero_state.gold == starting_gold + 700, "Full dungeon completion must grant exactly 700 Gold while ordinary encounters grant no per-mob Gold.")
	var final_owned_equipment: Array = simulation.hero_state.equipment.get_all_items() + simulation.hero_state.inventory.get_items()
	assert(final_owned_equipment.size() == starting_owned_equipment_count + 1, "Full dungeon completion must grant exactly one equipment item whether it equips or replaces the test Belt.")
	var completion_item = null
	for owned_item in final_owned_equipment:
		if owned_item.item_level == 10 and (owned_item.rarity == 2 or owned_item.rarity == 3):
			completion_item = owned_item
			break
	assert(completion_item != null, "The guaranteed first-dungeon completion reward must exist among equipped or retained equipment.")
	assert(completion_item.item_level == 10, "The guaranteed first-dungeon completion item must be ilvl 10.")
	assert(completion_item.rarity == 2 or completion_item.rarity == 3, "The guaranteed first-dungeon completion item must be Blue/Rare or Purple/Epic.")
	assert(not dungeon.has_map_target(), "A completed dungeon must lose its active map target so its marker disappears immediately.")
	assert(simulation.world_state.get_activity_id_at_hex(dungeon_hex).is_empty(), "A completed dungeon must release its reserved map hex.")
	assert(simulation.dungeon_system.get_discovered_dungeons().is_empty(), "A completed dungeon must no longer appear in the active discovered-dungeon map view.")
	var city_center: Vector2i = simulation.hex_map.definition.starting_city_center
	var return_route: Array[Vector2i] = simulation.hex_map.find_path(dungeon_hex, city_center)
	assert(simulation.travel_system.get_remaining_steps() == return_route.size() - 1, "Dungeon completion must start the exact real route back to the city.")
	for route_index in range(1, return_route.size()):
		var tick_before: int = simulation.world_clock.world_tick
		simulation.advance_time(10.0)
		assert(simulation.world_clock.world_tick == tick_before + 1, "Each dungeon return step must consume exactly one world tick.")
		assert(simulation.world_state.hero_position == return_route[route_index], "Dungeon return travel must move the hero exactly one route hex per tick.")
		if route_index < return_route.size() - 1:
			assert(simulation.hero_state.loop_state == HeroState.DUNGEON_RETURNING_TO_CITY, "The hero must stay in dungeon-return travel until reaching the city.")
	assert(simulation.hero_state.loop_state == HeroState.VISITING_MARKET, "Returning from a completed dungeon must resume the normal city market cycle.")
	assert(simulation.dungeon_runner.active_dungeon == null, "DungeonRunner must release the completed expedition after the hero reaches the city.")
	var ordinary_stats: Dictionary = simulation.get_combat_results("mine_troglodyte")
	var boss_stats: Dictionary = simulation.get_combat_results("deep_devourer")
	assert(int(ordinary_stats.get("total", 0)) == 3 and int(ordinary_stats.get("wins", 0)) == 3, "Combat statistics must record all three real troglodyte fights.")
	assert(int(boss_stats.get("total", 0)) == 1 and int(boss_stats.get("wins", 0)) == 1, "Combat statistics must record the real boss fight.")

func test_dungeon_death_and_instant_resurrection() -> void:
	var simulation = SimulationScript.new(8102, null)
	var dungeon = prepare_dungeon_at_entrance(simulation)
	var starting_gold: int = simulation.hero_state.gold
	var starting_equipment_count: int = simulation.hero_state.equipment.get_all_items().size()
	simulation.hero_state.current_hp = 1.0
	finish_current_dungeon_fight(simulation)
	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Losing a dungeon fight must enter the shared dead/respawning hero state.")
	assert(simulation.dungeon_runner.respawn_ticks_remaining == 100, "Dungeon death must start the normal 100-tick resurrection timer.")
	assert(simulation.quest_runner.respawn_ticks_remaining == 0, "Dungeon death must not fake ownership through QuestRunner.")
	assert(simulation.get_respawn_ticks_remaining() == 100, "Simulation must expose the active dungeon respawn timer to UI and god abilities.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.starting_city_center, "A dead dungeon hero must return to the safe city map position.")
	assert(not dungeon.completed, "Death before the boss must not mark the dungeon complete.")
	assert(simulation.hero_state.experience == 0, "A hero who dies in the first dungeon fight must not receive victory XP.")
	assert(simulation.hero_state.gold == starting_gold, "A failed dungeon attempt must not grant the 700-Gold completion reward.")
	assert(simulation.hero_state.equipment.get_all_items().size() == starting_equipment_count, "A failed dungeon attempt must not grant completion equipment.")
	assert(dungeon.has_map_target(), "A failed dungeon must remain on the map for a later readiness-gated retry.")

	var energy_before: float = simulation.god_state.energy
	assert(simulation.use_instant_resurrection(), "Instant resurrection must work for a dungeon-owned death state too.")
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Instant resurrection after dungeon death must use normal city recovery.")
	assert(is_equal_approx(simulation.hero_state.current_hp, 1.0), "Dungeon instant resurrection must restore exactly one HP.")
	assert(is_equal_approx(simulation.god_state.energy, energy_before - 50.0), "A fresh 100-tick dungeon resurrection must cost 50 Divine Energy.")
