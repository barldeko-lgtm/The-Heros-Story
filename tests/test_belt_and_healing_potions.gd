extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const BeltPotionRulesScript = preload("res://scripts/items/belt_potion_rules.gd")

const BELT_DIR := "res://data/items/visual_families/ironward_vanguard"

class EmptyRng:
	extends RefCounted

	func randf() -> float:
		return 0.5

	func randi_range(from: int, _to: int) -> int:
		return from

func _init() -> void:
	test_potion_data_and_belt_comparison()
	test_full_preparation_and_between_fight_use()
	test_dungeon_requires_full_belt()
	test_belt_purchase_preserves_new_full_loadout_budget()
	print("PASS: Belt utility, ilvl 10/20 healing potions, full-slot preparation, and dungeon-only between-fight healing follow the approved rules.")
	quit()

func test_potion_data_and_belt_comparison() -> void:
	var simulation = SimulationScript.new(9101, null)
	var potion_definitions: Array = simulation.shop_system.get_healing_potion_definitions()
	assert(potion_definitions.size() == 2, "Starting City must expose exactly the currently approved ilvl 10 and ilvl 20 healing potions.")
	assert(potion_definitions[0].potion_level == 10 and is_equal_approx(potion_definitions[0].healing_amount, 100.0) and potion_definitions[0].shop_price == 100, "ilvl 10 potion must heal 100 HP and cost 100 Gold.")
	assert(potion_definitions[1].potion_level == 20 and is_equal_approx(potion_definitions[1].healing_amount, 150.0) and potion_definitions[1].shop_price == 200, "ilvl 20 potion must heal 150 HP and cost 200 Gold.")
	assert(potion_definitions[0].icon_texture != null and potion_definitions[0].icon_texture.get_size() == Vector2(550.0, 550.0), "ilvl 10 potion must use the supplied 550x550 inventory sprite.")
	assert(potion_definitions[1].icon_texture != null and potion_definitions[1].icon_texture.get_size() == Vector2(550.0, 550.0), "ilvl 20 potion must use the supplied 550x550 inventory sprite.")

	var common_definition = load("%s/ironward_belt.tres" % BELT_DIR)
	var uncommon_definition = load("%s/ironward_belt_uncommon.tres" % BELT_DIR)
	var rare_definition = load("%s/ironward_belt_rare.tres" % BELT_DIR)
	var common10 = simulation.item_generator.generate(common_definition, 10, EmptyRng.new())
	var uncommon10 = simulation.item_generator.generate(uncommon_definition, 10, EmptyRng.new())
	var rare10 = simulation.item_generator.generate(rare_definition, 10, EmptyRng.new())
	var common20 = simulation.item_generator.generate(common_definition, 20, EmptyRng.new())
	var uncommon20 = simulation.item_generator.generate(uncommon_definition, 20, EmptyRng.new())
	var rules = BeltPotionRulesScript.new()
	assert(rules.get_capacity(common10) == 1 and rules.get_capacity(uncommon10) == 2 and rules.get_capacity(rare10) == 3, "White/Green/Blue Belts must provide 1/2/3 potion slots.")
	assert(is_equal_approx(rules.get_potential_healing(rare10), 300.0), "Blue ilvl 10 Belt must represent 3 x 100 = 300 potential healing.")
	assert(is_equal_approx(rules.get_potential_healing(common20), 150.0), "White ilvl 20 Belt must represent 1 x 150 = 150 potential healing.")

	simulation.hero_state.equipment.replace_item(rare10)
	simulation.refresh_combat_stats()
	var weaker_utility: Dictionary = simulation.equipment_evaluator.evaluate(simulation.hero_state, common20)
	assert(not bool(weaker_utility["should_equip"]), "White ilvl 20 Belt must not replace Blue ilvl 10 when its total potion healing is lower, despite higher Belt Health.")
	var equal_utility: Dictionary = simulation.equipment_evaluator.evaluate(simulation.hero_state, uncommon20)
	assert(bool(equal_utility["should_equip"]), "Green ilvl 20 Belt must replace Blue ilvl 10 when both provide 300 potion healing and ilvl 20 has more inherent Health.")
	assert(rare10.get_tooltip_text().contains("Слоты зелий: 3") and rare10.get_tooltip_text().contains("300 HP"), "Belt tooltip must expose potion capacity and potential healing.")

func test_full_preparation_and_between_fight_use() -> void:
	var simulation = SimulationScript.new(9102, null)
	var uncommon_definition = load("%s/ironward_belt_uncommon.tres" % BELT_DIR)
	var belt20 = simulation.item_generator.generate(uncommon_definition, 20, EmptyRng.new())
	simulation.hero_state.equipment.replace_item(belt20)
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	simulation.hero_state.gold = 300
	var potion_definitions: Array = simulation.shop_system.get_healing_potion_definitions()

	var plan: Dictionary = simulation.potion_preparation_system.get_full_loadout_plan(simulation.hero_state, potion_definitions)
	assert(bool(plan["can_prepare"]) and int(plan["capacity"]) == 2, "Green Belt must require both of its two slots to be filled before a dungeon.")
	assert(int(plan["purchase_cost"]) == 300 and is_equal_approx(float(plan["total_healing"]), 250.0), "With 300 Gold, a two-slot ilvl 20 Belt must maximize healing with one ilvl 20 and one ilvl 10 potion.")
	var preparation: Dictionary = simulation.potion_preparation_system.prepare_full_loadout(simulation.hero_state, potion_definitions)
	assert(bool(preparation["can_prepare"]) and simulation.hero_state.gold == 0, "Executing preparation must purchase the complete planned loadout.")
	assert(simulation.hero_state.prepared_healing_potion_levels.size() == 2 and simulation.hero_state.inventory.get_total_healing_potion_count() == 2, "Prepared potions must remain physical consumables in the hero Inventory.")

	simulation.hero_state.current_hp = simulation.combat_stats.max_hp - 250.0
	var ordinary_use: Dictionary = simulation.potion_preparation_system.use_between_fight_potions(simulation.hero_state, simulation.combat_stats.max_hp, false, potion_definitions)
	assert(int(ordinary_use["consumed_count"]) == 2 and is_equal_approx(float(ordinary_use["actual_healing"]), 250.0), "An ordinary between-fight window may consume multiple potions when all healing is useful without overheal.")
	assert(is_equal_approx(simulation.hero_state.current_hp, simulation.combat_stats.max_hp), "Multiple efficient potions may restore the hero to full HP in the same between-fight window.")
	assert(simulation.hero_state.inventory.get_total_healing_potion_count() == 0 and simulation.hero_state.prepared_healing_potion_levels.is_empty(), "Consumed potions must leave both Inventory and Belt preparation.")

	simulation.hero_state.inventory.add_healing_potion(20)
	simulation.hero_state.inventory.add_healing_potion(10, 2)
	simulation.hero_state.prepared_healing_potion_levels = [20, 10, 10]
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp - 200.0
	var exact_ordinary_use: Dictionary = simulation.potion_preparation_system.use_between_fight_potions(simulation.hero_state, simulation.combat_stats.max_hp, false, potion_definitions)
	assert(int(exact_ordinary_use["consumed_count"]) == 2 and is_equal_approx(float(exact_ordinary_use["actual_healing"]), 200.0), "Ordinary healing must choose the combination that restores the most HP without overheal, so 100+100 beats stopping after a 150 potion when 200 HP is missing.")
	assert(simulation.hero_state.inventory.get_healing_potion_count(20) == 1, "The stronger 150-HP potion must be preserved when two weaker potions produce an exact no-overheal ordinary-room heal.")

	simulation.hero_state.inventory.add_healing_potion(10)
	simulation.hero_state.prepared_healing_potion_levels = [10, 20]
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp - 180.0
	var boss_use: Dictionary = simulation.potion_preparation_system.use_between_fight_potions(simulation.hero_state, simulation.combat_stats.max_hp, true, potion_definitions)
	assert(int(boss_use["consumed_count"]) == 2, "Before the boss, the hero may consume as many prepared potions as needed to reach full HP.")
	assert(is_equal_approx(float(boss_use["overheal"]), 70.0), "Boss preparation may accept overheal when that is required to reach full HP.")
	assert(is_equal_approx(simulation.hero_state.current_hp, simulation.combat_stats.max_hp), "Boss preparation must prioritize entering the boss fight at full HP when the carried potions allow it.")

func test_dungeon_requires_full_belt() -> void:
	var simulation = SimulationScript.new(9103, null)
	var common_definition = load("%s/ironward_belt.tres" % BELT_DIR)
	var common10 = simulation.item_generator.generate(common_definition, 10, EmptyRng.new())
	simulation.hero_state.equipment.replace_item(common10)
	simulation.refresh_combat_stats()
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	dungeon.discover("test")

	simulation.hero_state.gold = 0
	assert(not simulation.try_start_discovered_dungeon_trip(1), "A known dungeon must remain blocked when the hero cannot fill every Belt slot.")
	assert(simulation.debug_log.get_text().contains("полностью заполнить"), "Dungeon readiness log must explain missing full Belt preparation.")

	simulation.hero_state.gold = 100
	assert(simulation.try_start_discovered_dungeon_trip(2), "The dungeon may schedule preparation once the hero can buy enough potions to fill every Belt slot.")
	assert(simulation.hero_state.loop_state == HeroState.PREPARING_DUNGEON, "Missing dungeon potions must schedule a dedicated preparation/purchase world tick before travel.")
	var preparation_start_log: String = simulation.debug_log.get_text()
	assert(preparation_start_log.contains("отправился за зельями") and not preparation_start_log.contains("выделил отдельный тик"), "The preparation-start narration must describe the hero action without exposing the internal dedicated-tick implementation wording.")
	assert(simulation.hero_state.gold == 100 and simulation.hero_state.inventory.get_total_healing_potion_count() == 0, "Scheduling the potion-purchase tick must not spend Gold or create potions early.")
	var purchase_tick_before: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == purchase_tick_before + 1, "Buying the missing full-Belt loadout must consume exactly one world tick.")
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON, "Dungeon travel may begin only after the dedicated potion-purchase tick completes.")
	assert(simulation.hero_state.gold == 0 and simulation.hero_state.prepared_healing_potion_levels == [10], "The dedicated potion tick must buy and prepare the full one-slot ilvl 10 loadout for exactly 100 Gold.")
	assert(simulation.hero_state.inventory.get_healing_potion_count(10) == 1, "Prepared dungeon potion must still exist in the hero Inventory until consumed.")

func test_belt_purchase_preserves_new_full_loadout_budget() -> void:
	var simulation = SimulationScript.new(9104, null)
	var common_definition = load("%s/ironward_belt.tres" % BELT_DIR)
	var uncommon_definition = load("%s/ironward_belt_uncommon.tres" % BELT_DIR)
	var common10 = simulation.item_generator.generate(common_definition, 10, EmptyRng.new())
	var uncommon10 = simulation.item_generator.generate(uncommon_definition, 10, EmptyRng.new())
	simulation.hero_state.equipment.replace_item(common10)
	simulation.refresh_combat_stats()
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	dungeon.discover("test")

	# Green ilvl 10 Belt costs 1500 Gold and would raise capacity from one to two slots.
	# With 1600 Gold the hero can afford the Belt itself, but would have only 100 Gold left,
	# not enough to fill both new slots. Preparation priority must therefore block this purchase.
	simulation.shop_system.listings = [{"item_instance": uncommon10}]
	simulation.hero_state.gold = 1600
	simulation.hero_state.loop_state = HeroState.SHOPPING
	var result: Dictionary = simulation.advance_shop_purchase_tick(5)
	assert(not bool(result.get("purchased", false)), "A Belt upgrade must not spend Gold that would make its own newly enlarged full potion loadout unaffordable.")
	assert(simulation.hero_state.equipment.get_item("belt") == common10, "The old one-slot Belt must remain equipped when the two-slot upgrade would break dungeon preparation priority.")
	assert(simulation.hero_state.loop_state == HeroState.PREPARING_DUNGEON, "After declining the unsafe Belt purchase, the missing current-Belt potion must be bought on a separate world tick.")
	assert(simulation.hero_state.gold == 1600 and simulation.hero_state.prepared_healing_potion_levels.is_empty(), "The equipment-shopping tick must not also buy the dungeon potion.")
	var purchase_tick_before: int = simulation.world_clock.world_tick
	simulation.advance_time(10.0)
	assert(simulation.world_clock.world_tick == purchase_tick_before + 1, "The current-Belt potion purchase must consume its own world tick.")
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON, "Travel must begin after the separate potion-purchase tick.")
	assert(simulation.hero_state.gold == 1500 and simulation.hero_state.prepared_healing_potion_levels == [10], "The dedicated potion tick must spend exactly 100 Gold on the current one-slot Belt preparation.")
