extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")

func _init() -> void:
	test_rank_availability_and_costs()
	test_affordable_training_uses_one_tick_before_shop()
	test_unaffordable_training_adds_no_extra_tick()
	test_multiple_available_upgrades_take_separate_ticks()
	test_dungeon_potion_budget_is_protected()
	test_curiosity_axis_controls_purchase_order()
	print("PASS: Skill training and equipment shopping follow Curious/Conservative priority, preserve neutral skill-first behaviour, and protect dungeon-potion Gold.")
	quit()

func test_rank_availability_and_costs() -> void:
	var simulation = SimulationScript.new(9301)
	var training = simulation.skill_training_system
	var expected_costs := [500, 650, 850, 1100, 1450, 1900, 2450, 3200, 4150]
	for index in expected_costs.size():
		assert(training.get_rank_cost(index + 2) == expected_costs[index], "Skill rank costs must match the approved SL2-SL10 curve.")
	assert(simulation.hero_progression.get_max_unlocked_skill_level(HeroProgressionScript.POWER_STRIKE_SKILL_ID, 9) == 1, "Power Strike must still cap at Skill Level 1 before hero level 10.")
	assert(simulation.hero_progression.get_max_unlocked_skill_level(HeroProgressionScript.POWER_STRIKE_SKILL_ID, 10) == 2, "Power Strike Skill Level 2 must unlock at hero level 10.")
	assert(simulation.hero_progression.get_max_unlocked_skill_level(HeroProgressionScript.POWER_STRIKE_SKILL_ID, 15) == 3, "Power Strike Skill Level 3 must unlock at hero level 15.")
	assert(simulation.hero_progression.get_max_unlocked_skill_level(HeroProgressionScript.BATTLE_GUARD_SKILL_ID, 14) == 1, "Battle Guard must still cap at Skill Level 1 before hero level 15.")
	assert(simulation.hero_progression.get_max_unlocked_skill_level(HeroProgressionScript.BATTLE_GUARD_SKILL_ID, 15) == 2, "Battle Guard Skill Level 2 must unlock at hero level 15.")
	simulation.hero_state.level = 15
	simulation.hero_state.power_strike_skill_level = 2
	simulation.hero_state.battle_guard_skill_level = 1
	simulation.hero_state.gold = 500
	var affordable_candidate: Dictionary = training.select_affordable_upgrade(simulation.hero_state)
	assert(str(affordable_candidate.get("skill_id", "")) == HeroProgressionScript.BATTLE_GUARD_SKILL_ID, "If the earlier skill's next rank is too expensive, an affordable later skill upgrade must still be selected.")

func test_affordable_training_uses_one_tick_before_shop() -> void:
	var simulation = SimulationScript.new(9302)
	prepare_level_10_skills(simulation)
	var sale_definition = load("res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_chestplate.tres")
	var sale_rng := RandomNumberGenerator.new()
	sale_rng.seed = 9302
	var sale_item = simulation.item_generator.generate(sale_definition, 5, sale_rng)
	simulation.hero_state.inventory.add_item(sale_item)
	simulation.hero_state.gold = 450
	simulation.hero_state.loop_state = HeroState.VISITING_MARKET
	simulation.shop_system.listings = []

	var market_tick_before: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == market_tick_before + 1, "Selling ordinary loot must keep its existing dedicated market world tick.")
	assert(simulation.hero_state.loop_state == HeroState.SHOPPING, "Market sale must still lead into the existing SHOPPING state.")
	assert(simulation.hero_state.inventory.get_items().is_empty() and simulation.hero_state.gold == 500, "Training affordability must see Gold gained by the immediately preceding loot-sale tick.")
	assert(simulation.debug_log.get_text().contains("+50 золота"), "The real market tick must still narrate the sold loot before training begins.")
	var tick_before: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == tick_before + 1, "Buying one Skill Level must consume exactly one world tick.")
	assert(simulation.hero_state.power_strike_skill_level == 2, "The first affordable unlocked Power Strike rank must be purchased.")
	assert(simulation.hero_state.gold == 0, "Skill Level 2 must spend exactly 500 Gold.")
	assert(simulation.hero_state.loop_state == HeroState.SHOPPING, "After a training tick, equipment shopping must wait until a later tick.")
	assert(simulation.debug_log.get_text().contains("Мощный удар") and simulation.debug_log.get_text().contains("уровня 2") and simulation.debug_log.get_text().contains("500 золота"), "Training must write a clear economy-layer log entry.")

	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "With no further affordable training or equipment, the following normal shopping tick must finish the city phase.")

func test_unaffordable_training_adds_no_extra_tick() -> void:
	var simulation = SimulationScript.new(9303)
	prepare_level_10_skills(simulation)
	simulation.hero_state.gold = 499
	simulation.hero_state.loop_state = HeroState.SHOPPING
	simulation.shop_system.listings = []

	var result: Dictionary = simulation.advance_shop_purchase_tick(3)
	assert(not bool(result.get("purchased", false)), "An unaffordable Skill Level must not be purchased.")
	assert(simulation.hero_state.power_strike_skill_level == 1 and simulation.hero_state.gold == 499, "Failed affordability must not mutate rank or Gold.")
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "If training is unaffordable, the same tick must continue through the existing empty-shop path instead of adding a training delay.")

func test_multiple_available_upgrades_take_separate_ticks() -> void:
	var simulation = SimulationScript.new(9304)
	simulation.hero_state.level = 15
	simulation.hero_state.power_strike_skill_level = 2
	simulation.hero_state.battle_guard_skill_level = 1
	simulation.hero_state.gold = 1150
	simulation.hero_state.loop_state = HeroState.SHOPPING
	simulation.shop_system.listings = []

	var first_result: Dictionary = simulation.advance_shop_purchase_tick(4)
	assert(str(first_result.get("skill_id", "")) == HeroProgressionScript.POWER_STRIKE_SKILL_ID, "When both are affordable, current deterministic base-skill order must train Power Strike first.")
	assert(simulation.hero_state.power_strike_skill_level == 3 and simulation.hero_state.battle_guard_skill_level == 1 and simulation.hero_state.gold == 500, "First training tick must buy only Power Strike SL3 for 650 Gold.")
	assert(simulation.hero_state.loop_state == HeroState.SHOPPING, "A second available rank must wait for another world tick.")

	var second_result: Dictionary = simulation.advance_shop_purchase_tick(5)
	assert(str(second_result.get("skill_id", "")) == HeroProgressionScript.BATTLE_GUARD_SKILL_ID, "The next training tick must buy the remaining affordable Battle Guard rank.")
	assert(simulation.hero_state.battle_guard_skill_level == 2 and simulation.hero_state.gold == 0, "Second training tick must spend the remaining 500 Gold on Battle Guard SL2.")

	simulation.advance_shop_purchase_tick(6)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "Only a later no-training shopping tick may finish the city phase.")

func test_dungeon_potion_budget_is_protected() -> void:
	var simulation = SimulationScript.new(9305)
	prepare_level_10_skills(simulation)
	var belt_definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var rng := RandomNumberGenerator.new()
	rng.seed = 9305
	var belt = simulation.item_generator.generate(belt_definition, 5, rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.refresh_combat_stats()
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	dungeon.discover("test")
	simulation.hero_state.gold = 550
	simulation.hero_state.loop_state = HeroState.SHOPPING
	simulation.shop_system.listings = []

	var result: Dictionary = simulation.advance_shop_purchase_tick(7)
	assert(not bool(result.get("purchased", false)), "A 500-Gold Skill Level must not consume Gold reserved for the current mandatory dungeon potion.")
	assert(simulation.hero_state.power_strike_skill_level == 1 and simulation.hero_state.gold == 550, "Protected potion Gold must leave the Skill Level and wallet unchanged.")
	assert(simulation.hero_state.loop_state == HeroState.PREPARING_DUNGEON, "After training is blocked by the protected budget, the same shopping tick must continue to the existing dungeon-preparation decision.")

func test_curiosity_axis_controls_purchase_order() -> void:
	var conservative = make_priority_test_simulation(9310, HeroTraitsScript.CONSERVATIVE)
	var conservative_first: Dictionary = conservative.advance_shop_purchase_tick(10)
	assert(bool(conservative_first.get("purchased", false)) and conservative_first.get("item_instance") != null, "Conservative must buy a meaningful equipment upgrade before an affordable Skill Level.")
	assert(conservative.hero_state.power_strike_skill_level == 1, "Conservative equipment-first tick must not also train a Skill Level.")
	assert(conservative.hero_state.loop_state == HeroState.SHOPPING, "Conservative must remain in shopping when an affordable lower-priority Skill Level still exists.")
	var conservative_second: Dictionary = conservative.advance_shop_purchase_tick(11)
	assert(str(conservative_second.get("skill_id", "")) == HeroProgressionScript.POWER_STRIKE_SKILL_ID, "After meaningful equipment is exhausted, Conservative must still buy the lower-priority Skill Level.")

	var curious = make_priority_test_simulation(9311, HeroTraitsScript.CURIOUS)
	var curious_first: Dictionary = curious.advance_shop_purchase_tick(12)
	assert(str(curious_first.get("skill_id", "")) == HeroProgressionScript.POWER_STRIKE_SKILL_ID, "Curious must buy an affordable Skill Level before meaningful equipment.")
	assert(curious.shop_system.get_listings()[0].get("item_instance") != null, "Curious training tick must leave the equipment listing untouched until a later tick.")
	var curious_second: Dictionary = curious.advance_shop_purchase_tick(13)
	assert(bool(curious_second.get("purchased", false)) and curious_second.get("item_instance") != null, "Curious must still buy meaningful equipment after preferred training is exhausted.")

	var neutral = make_priority_test_simulation(9312, "")
	neutral.hero_state.personality_axis_values[neutral.trait_development.AXIS_CURIOSITY] = -35
	var neutral_first: Dictionary = neutral.advance_shop_purchase_tick(14)
	assert(str(neutral_first.get("skill_id", "")) == HeroProgressionScript.POWER_STRIKE_SKILL_ID, "A hidden Conservative-leaning value without an established trait must keep the neutral Warrior default: Skill Level first.")

	var conservative_fallback = make_priority_test_simulation(9313, HeroTraitsScript.CONSERVATIVE)
	conservative_fallback.hero_state.gold = 500
	var fallback_result: Dictionary = conservative_fallback.advance_shop_purchase_tick(15)
	assert(str(fallback_result.get("skill_id", "")) == HeroProgressionScript.POWER_STRIKE_SKILL_ID, "Conservative must fall back to an affordable Skill Level when the preferred equipment upgrade is not affordable.")

func make_priority_test_simulation(seed_value: int, curiosity_trait: String):
	var simulation = SimulationScript.new(seed_value)
	prepare_level_10_skills(simulation)
	simulation.trait_development.reset_state(simulation.hero_state)
	if curiosity_trait == HeroTraitsScript.CURIOUS:
		simulation.trait_development.apply_movement(simulation.hero_state, simulation.trait_development.AXIS_CURIOSITY, simulation.trait_development.ACTIVATION_THRESHOLD)
	elif curiosity_trait == HeroTraitsScript.CONSERVATIVE:
		simulation.trait_development.apply_movement(simulation.hero_state, simulation.trait_development.AXIS_CURIOSITY, -simulation.trait_development.ACTIVATION_THRESHOLD)
	var definition = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var item = simulation.item_generator.generate(definition, 10, rng)
	simulation.shop_system.listings = [{"item_instance": item}]
	simulation.hero_state.gold = 1500
	simulation.hero_state.loop_state = HeroState.SHOPPING
	return simulation

func prepare_level_10_skills(simulation) -> void:
	simulation.hero_state.level = 10
	simulation.hero_state.power_strike_skill_level = 1
	simulation.hero_state.battle_guard_skill_level = 1
