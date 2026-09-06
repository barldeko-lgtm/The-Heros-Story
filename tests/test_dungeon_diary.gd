extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")

func _init() -> void:
	var simulation = SimulationScript.new(9201, null)
	simulation.hero_state.hero_name = "Алексей"
	equip_test_belt(simulation)
	simulation.hero_state.gold = 100000

	assert(simulation.use_divine_vision(), "Focused dungeon Diary test requires one discovered Starting Region dungeon.")
	var dungeon = find_vision_discovered_dungeon(simulation)
	assert(dungeon != null, "Vision must expose the discovered dungeon instance used by the Diary test.")
	assert(simulation.diary.entries.size() == 1, "Dungeon discovery must add exactly one Diary entry.")
	assert(simulation.diary.entries.back().contains(dungeon.definition.display_name), "Dungeon discovery Diary entry must use the real dungeon name.")

	assert(simulation.try_start_discovered_dungeon_trip(2), "Known first-attempt dungeon must become the hero's next activity when preparation is possible.")
	assert(simulation.hero_state.loop_state == HeroState.PREPARING_DUNGEON, "Missing Belt potions must reserve the dedicated preparation tick.")
	var diary_count_before_preparation: int = simulation.diary.entries.size()
	var preparation: Dictionary = simulation.advance_dungeon_potion_purchase_tick(3)
	assert(bool(preparation.get("can_prepare", false)), "Dungeon preparation must succeed for the focused Diary test.")
	var bought_count: int = get_purchase_count(preparation)
	assert(bought_count > 0, "Focused dungeon Diary test must actually purchase at least one healing potion.")
	assert(simulation.diary.entries.size() == diary_count_before_preparation + 2, "Starting a prepared dungeon with purchases must add one attempt entry and one potion-purchase entry.")
	var attempt_entry: String = simulation.diary.entries[diary_count_before_preparation]
	var potion_entry: String = simulation.diary.entries[diary_count_before_preparation + 1]
	assert(attempt_entry.contains(dungeon.definition.display_name), "Dungeon attempt Diary entry must name the real dungeon.")
	assert(potion_entry.contains(dungeon.definition.display_name) and potion_entry.contains(str(bought_count)), "Potion Diary entry must name the dungeon and the real number of purchased potions.")

	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Focused completion test must place the hero on the active dungeon hex.")
	simulation.dungeon_runner.ordinary_encounters_completed = dungeon.definition.ordinary_encounter_count
	simulation.hero_state.loop_state = HeroState.DOING_DUNGEON
	var boss = simulation.dungeon_runner.get_current_mob_definition()
	assert(boss != null, "Focused dungeon completion Diary test requires the authored boss encounter.")
	var diary_count_before_completion: int = simulation.diary.entries.size()
	var victory = CombatResultScript.new(true, simulation.combat_stats.max_hp, 0.0, 1.0, [])
	simulation.complete_dungeon_combat(boss, victory, true, 77)
	assert(dungeon.completed, "Boss victory must complete the focused dungeon instance.")
	assert(simulation.diary.entries.size() == diary_count_before_completion + 1, "Dungeon completion reward must create one combined Diary entry, not a duplicate generic Rare/Epic acquisition entry.")
	var completion_entry: String = simulation.diary.entries.back()
	var reward_item = find_rare_or_epic_item(simulation)
	assert(reward_item != null, "Completed dungeon must grant its Rare/Epic equipment reward.")
	assert(completion_entry.begins_with("Тик 77 — "), "Dungeon completion Diary entry must keep the real combat world tick.")
	assert(completion_entry.contains(dungeon.definition.display_name), "Dungeon completion Diary entry must name the completed dungeon.")
	assert(completion_entry.contains(str(dungeon.definition.completion_gold_reward)), "Dungeon completion Diary entry must include the real Gold reward.")
	assert(completion_entry.contains(reward_item.definition.display_name), "Dungeon completion Diary entry must include the actual equipment reward name.")

	print("PASS: Dungeon Diary covers discovery, attempt decision, purchased potion count, and one combined completion reward entry.")
	quit()

func equip_test_belt(simulation) -> void:
	var belt_definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var rng := RandomNumberGenerator.new()
	rng.seed = 9201
	var belt = simulation.item_generator.generate(belt_definition, 5, rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp

func find_vision_discovered_dungeon(simulation):
	for dungeon in simulation.dungeon_system.get_all_dungeons():
		if dungeon != null and dungeon.discovered and dungeon.discovery_source == "vision":
			return dungeon
	return null

func get_purchase_count(preparation: Dictionary) -> int:
	var total: int = 0
	for count in preparation.get("purchase_counts", {}).values():
		total += int(count)
	return total

func find_rare_or_epic_item(simulation):
	for item in simulation.hero_state.equipment.get_all_items():
		if item != null and int(item.rarity) >= 2:
			return item
	for item in simulation.hero_state.inventory.get_items():
		if item != null and int(item.rarity) >= 2:
			return item
	return null
