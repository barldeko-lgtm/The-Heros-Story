extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_retry_thresholds()
	test_failed_first_fight_blocks_immediate_retry_until_power_growth()
	print("PASS: Dungeon retry readiness uses +25% / +15% / +10% Power growth and blocks immediate repeat attempts after death.")
	quit()

func test_retry_thresholds() -> void:
	var simulation = SimulationScript.new(8301, null)
	var evaluator = simulation.dungeon_evaluator
	assert(is_equal_approx(evaluator.get_retry_growth(0, false), 0.25), "Dying before killing any ordinary dungeon enemy must require +25% HeroPower.")
	assert(is_equal_approx(evaluator.get_retry_growth(1, false), 0.15), "Killing at least one ordinary enemy but not reaching the boss must require +15% HeroPower.")
	assert(is_equal_approx(evaluator.get_retry_growth(2, false), 0.15), "Any ordinary-room progress short of the boss must keep the +15% HeroPower retry gate.")
	assert(is_equal_approx(evaluator.get_retry_growth(3, true), 0.10), "Reaching the boss and dying must require +10% HeroPower.")
	assert(is_equal_approx(evaluator.get_required_retry_power(100.0, 0, false), 125.0), "A 100-Power no-kill failure must require 125 Power.")
	assert(is_equal_approx(evaluator.get_required_retry_power(100.0, 1, false), 115.0), "A 100-Power ordinary-progress failure must require 115 Power.")
	assert(is_equal_approx(evaluator.get_required_retry_power(100.0, 3, true), 110.0), "A 100-Power boss failure must require 110 Power.")

	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	dungeon.record_failed_attempt(100.0, 0, false)
	assert(not bool(evaluator.evaluate_retry_readiness(dungeon, 124.99)["ready"]), "A retry below the remembered required Power must stay blocked.")
	assert(bool(evaluator.evaluate_retry_readiness(dungeon, 125.0)["ready"]), "A retry at the remembered required Power must become valid.")
	dungeon.record_failed_attempt(125.0, 3, true)
	assert(dungeon.failed_attempt_count == 2, "Each failed retry must be remembered as another failed attempt.")
	assert(is_equal_approx(dungeon.last_failed_attempt_start_power, 125.0), "A later failure must replace the retry baseline with that attempt's own starting HeroPower.")
	assert(is_equal_approx(float(evaluator.evaluate_retry_readiness(dungeon, 137.5)["required_power"]), 137.5), "A boss failure on the later attempt must require 110% of that newer attempt baseline.")

func test_failed_first_fight_blocks_immediate_retry_until_power_growth() -> void:
	var simulation = SimulationScript.new(8302, null)
	var belt_definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var belt_rng := RandomNumberGenerator.new()
	belt_rng.seed = 8302
	var belt = simulation.item_generator.generate(belt_definition, 10, belt_rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.hero_state.inventory.add_healing_potion(10)
	simulation.hero_state.prepared_healing_potion_levels = [10]
	simulation.refresh_combat_stats()
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	dungeon.discover("test")
	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Retry integration test must place the hero on the real dungeon hex.")
	var attempt_start_power: float = simulation.get_hero_power()
	assert(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, attempt_start_power), "The first known-dungeon attempt must not have a retry gate.")
	var travel_result: Dictionary = simulation.dungeon_runner.advance(simulation.hero_state)
	assert(bool(travel_result.get("arrived", false)), "Starting on the dungeon hex must resolve travel as arrived.")
	assert(simulation.dungeon_runner.enter(simulation.hero_state), "The first dungeon attempt must enter normally.")

	simulation.hero_state.current_hp = 1.0
	simulation.start_dungeon_combat()
	simulation.advance_active_combat(1000000.0)
	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "The forced first-fight loss must enter dungeon-owned death.")
	assert(dungeon.failed_attempt_count == 1, "Dungeon runtime state must remember the failed attempt.")
	assert(is_equal_approx(dungeon.last_failed_attempt_start_power, attempt_start_power), "Failure memory must store HeroPower from the start of that attempt.")
	assert(dungeon.last_failure_ordinary_encounters_completed == 0, "First-fight death must remember zero defeated ordinary enemies.")
	assert(not dungeon.last_failure_reached_boss, "First-fight death must not be classified as reaching the boss.")
	var first_failure_readiness: Dictionary = simulation.dungeon_evaluator.evaluate_retry_readiness(dungeon, attempt_start_power)
	assert(is_equal_approx(float(first_failure_readiness["retry_growth"]), 0.25), "First-fight death must resolve the approved +25% retry growth.")
	assert(is_equal_approx(float(first_failure_readiness["required_power"]), attempt_start_power * 1.25), "First-fight death must require 125% of attempt-start HeroPower.")
	assert(simulation.debug_log.get_text().contains("+25%"), "Failure log must explain the +25% Power retry requirement.")

	assert(simulation.use_instant_resurrection(), "Retry integration test must be able to use the existing dungeon instant-resurrection path.")
	var recovery_ticks: int = 0
	while simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY and recovery_ticks < 10:
		simulation.advance_time(10.0)
		recovery_ticks += 1
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "After dungeon death the hero must recover and return to ordinary activity choice.")

	# Simulate the next normal post-quest shopping decision without granting any extra Power.
	simulation.hero_state.loop_state = HeroState.SHOPPING
	simulation.hero_state.gold = 0
	simulation.advance_shop_purchase_tick(simulation.world_clock.world_tick + 1)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "Below the retry threshold the hero must choose ordinary progression instead of running back to the dungeon.")
	assert(not simulation.travel_system.is_travelling(), "A blocked retry must not start another route to the dungeon.")
	assert(simulation.debug_log.get_text().contains("пока не готов снова идти в данж"), "The decision log must explain that the retry was postponed for insufficient Power.")

	var required_retry_power: float = float(simulation.dungeon_evaluator.evaluate_retry_readiness(dungeon, simulation.get_hero_power())["required_power"])
	while simulation.get_hero_power() < required_retry_power:
		simulation.hero_state.strength += 1
		simulation.hero_state.constitution += 1
		simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	var retry_start_power: float = simulation.get_hero_power()
	assert(retry_start_power >= required_retry_power, "Test setup must grow the hero to the remembered retry threshold.")

	simulation.hero_state.loop_state = HeroState.SHOPPING
	simulation.advance_shop_purchase_tick(simulation.world_clock.world_tick + 2)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON, "Once the required Power is reached, the next post-shopping decision must allow the retry.")
	assert(is_equal_approx(simulation.dungeon_runner.attempt_start_power, retry_start_power), "A new retry must record its own current HeroPower as the new attempt baseline.")
