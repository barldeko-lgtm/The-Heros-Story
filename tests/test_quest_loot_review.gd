extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_equipment_drop_waits_for_one_review_tick()
	test_no_drop_skips_review_state()
	test_quest_death_discards_unreviewed_equipment()
	print("PASS: Ordinary quest equipment waits until objective completion, costs one review tick when present, skips that tick when empty, and is discarded on quest death before review.")
	quit()

func test_equipment_drop_waits_for_one_review_tick() -> void:
	var simulation = SimulationScript.new(9501)
	simulation.hero_state.hero_name = "Герой"
	var mob_definition = simulation.quest_runner.quest_definition.mob_definition
	var drop_table = mob_definition.equipment_drop_table
	var original_drop_chance: float = drop_table.drop_chance
	drop_table.drop_chance = 1.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 9501

	var permanent_before: int = get_permanent_equipment_count(simulation)
	var first_generated: Dictionary = simulation.collect_mob_equipment_drop(mob_definition, rng)
	var second_generated: Dictionary = simulation.collect_mob_equipment_drop(mob_definition, rng)
	drop_table.drop_chance = original_drop_chance
	var first_item = first_generated.get("item_instance")
	var second_item = second_generated.get("item_instance")
	assert(first_item != null and second_item != null, "Guaranteed ordinary mob drops must generate concrete ItemInstances.")
	assert(simulation.pending_quest_equipment_drops.size() == 2, "All found equipment must wait together in the current quest loot buffer.")
	assert(get_permanent_equipment_count(simulation) == permanent_before, "Found equipment must not equip or enter permanent Inventory before the review point.")
	assert(not simulation.debug_log.get_text().contains(first_item.definition.display_name), "Found equipment must not be narrated as acquired before the review tick.")
	assert(not simulation.debug_log.get_text().contains(second_item.definition.display_name), "Every buffered equipment item must stay silent until the review tick.")

	simulation.hero_state.active_quest = simulation.quest_runner.quest_definition
	simulation.quest_runner.completed_mob_count = simulation.quest_runner.quest_definition.mob_count
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	simulation.hero_state.loop_state = HeroState.RECOVERING_AFTER_FIGHT
	var recovery_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats, true)
	assert(simulation.hero_state.loop_state == HeroState.REVIEWING_QUEST_LOOT, "Final recovery with carried equipment must stop at the loot-review phase before return travel.")
	assert(recovery_event.loot_review_pending, "Recovery narration fact must explicitly report the pending loot review.")
	assert(simulation.quest_narrator.describe(recovery_event).contains("разберёт найденную добычу"), "Quest review wording must come from QuestNarrator rather than Simulation.")

	var tick_before: int = simulation.world_clock.world_tick
	simulation.world_clock.complete_tick()
	assert(simulation.world_clock.world_tick == tick_before + 1, "Reviewing any number of found equipment items must consume exactly one world tick.")
	assert(simulation.pending_quest_equipment_drops.is_empty(), "The quest loot buffer must be empty after the review tick.")
	assert(simulation.hero_state.loop_state == HeroState.RETURNING_TO_CITY, "After review the hero must begin the normal return-to-city phase.")
	assert(get_permanent_equipment_count(simulation) == permanent_before + 2, "All reviewed items must route through normal Equipment/Inventory handling during the single review tick.")
	assert(simulation.debug_log.get_text().contains("разбирает найденное снаряжение"), "The dedicated review tick must be visible through QuestNarrator debug wording.")
	assert(simulation.debug_log.get_text().contains(first_item.definition.display_name), "Reviewed item results must still use the normal item narration at the review tick.")
	assert(simulation.debug_log.get_text().contains(second_item.definition.display_name), "Every reviewed item must be narrated at the same review tick.")

func test_no_drop_skips_review_state() -> void:
	var simulation = SimulationScript.new(9502)
	simulation.hero_state.active_quest = simulation.quest_runner.quest_definition
	simulation.quest_runner.completed_mob_count = simulation.quest_runner.quest_definition.mob_count
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	simulation.hero_state.loop_state = HeroState.RECOVERING_AFTER_FIGHT
	var recovery_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats, false)
	assert(not recovery_event.loot_review_pending, "A completed objective without equipment must not advertise a loot review.")
	assert(simulation.hero_state.loop_state == HeroState.RETURNING_TO_CITY, "Without equipment drops the hero must go straight into return travel with no extra review phase.")

func test_quest_death_discards_unreviewed_equipment() -> void:
	var simulation = SimulationScript.new(9503)
	var mob_definition = simulation.quest_runner.quest_definition.mob_definition
	var drop_table = mob_definition.equipment_drop_table
	var original_drop_chance: float = drop_table.drop_chance
	drop_table.drop_chance = 1.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 9503
	var generated: Dictionary = simulation.collect_mob_equipment_drop(mob_definition, rng)
	drop_table.drop_chance = original_drop_chance
	var permanent_before: int = get_permanent_equipment_count(simulation)
	assert(generated.get("item_instance") != null and simulation.pending_quest_equipment_drops.size() == 1)

	simulation.hero_state.loop_state = HeroState.DOING_QUEST
	simulation.hero_state.active_quest = simulation.quest_runner.quest_definition
	simulation.hero_state.current_hp = 1.0
	var original_attack: float = mob_definition.attack
	var original_crit_chance: float = mob_definition.crit_chance
	mob_definition.attack = 500.0
	mob_definition.crit_chance = 0.0
	simulation.start_combat()
	simulation.advance_active_combat(20.0)
	mob_definition.attack = original_attack
	mob_definition.crit_chance = original_crit_chance

	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Quest defeat must still enter the shared death/recovery flow.")
	assert(simulation.pending_quest_equipment_drops.is_empty(), "Quest defeat before the review point must discard all unreviewed quest equipment.")
	assert(get_permanent_equipment_count(simulation) == permanent_before, "Discarded unreviewed equipment must never leak into permanent Equipment/Inventory.")

func get_permanent_equipment_count(simulation) -> int:
	return simulation.hero_state.equipment.get_all_items().size() + simulation.hero_state.inventory.get_items().size()
