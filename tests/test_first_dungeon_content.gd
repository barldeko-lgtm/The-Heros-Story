extends SceneTree

const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"
const SECOND_DUNGEON_PATH := "res://data/dungeons/starting_region/0002_blackfang_settlement.tres"
const DungeonSystemScript = preload("res://scripts/dungeons/dungeon_system.gd")

func _init() -> void:
	var dungeon_system = DungeonSystemScript.new()
	var auto_loaded_dungeon = null
	for definition in dungeon_system.get_definitions():
		if definition.id == "abandoned_iron_mines":
			auto_loaded_dungeon = definition
			break
	assert(auto_loaded_dungeon != null, "DungeonSystem must automatically load ordinary DungeonDefinition resources from the region dungeon directories.")

	var dungeon = load(DUNGEON_PATH)
	assert(dungeon != null, "The first Starting Region dungeon definition must exist.")
	assert(dungeon.id == "abandoned_iron_mines", "The first dungeon must keep its stable id.")
	assert(dungeon.display_name == "Заброшенные железные шахты", "The first dungeon must keep its approved name.")
	assert(dungeon.ordinary_encounter_count == 3, "Abandoned Iron Mines must contain exactly three ordinary combat encounters before the boss.")
	assert(dungeon.ordinary_mob_definition != null, "The first dungeon must define one ordinary enemy type shared by all three encounters.")
	assert(dungeon.ordinary_mob_definition.id == "mine_troglodyte", "All three ordinary encounters must use the Mine Troglodyte.")
	assert(dungeon.ordinary_mob_definition.display_name == "Шахтный троглодит", "The ordinary dungeon enemy must keep its approved Russian name.")
	var ordinary_power: float = dungeon.ordinary_mob_definition.get_power()
	assert(ordinary_power >= 199.0 and ordinary_power <= 201.0, "Mine Troglodyte Power must remain approximately 200; got %.2f." % ordinary_power)
	assert(dungeon.ordinary_mob_definition.experience_reward == 150, "Mine Troglodyte must grant 150 normal combat XP.")
	assert(dungeon.ordinary_mob_definition.gold_reward == 0, "Ordinary dungeon encounters must not grant per-mob Gold.")
	assert(dungeon.ordinary_mob_definition.equipment_drop_table == null, "Ordinary dungeon encounters must not use normal equipment drops.")

	assert(dungeon.boss_mob_definition != null, "The first dungeon must define a separate unique boss.")
	assert(dungeon.boss_mob_definition.id == "deep_devourer", "The first dungeon boss must be the Deep Devourer.")
	assert(dungeon.boss_mob_definition.display_name == "Глубинный пожиратель", "The first dungeon boss must keep its approved Russian name.")
	var boss_power: float = dungeon.boss_mob_definition.get_power()
	assert(boss_power >= 299.0 and boss_power <= 301.0, "Deep Devourer Power must remain approximately 300; got %.2f." % boss_power)
	assert(boss_power > ordinary_power, "The dungeon boss must remain stronger than its ordinary enemy.")
	assert(dungeon.boss_mob_definition.experience_reward == 185, "Deep Devourer must grant 185 normal combat XP.")
	assert(dungeon.boss_mob_definition.gold_reward == 0, "Dungeon boss combat must not grant per-mob Gold before the separate completion reward.")
	assert(dungeon.boss_mob_definition.equipment_drop_table == null, "Dungeon boss combat must not use ordinary mob equipment drops.")

	assert(dungeon.completion_gold_reward == 700, "Abandoned Iron Mines completion must grant exactly 700 Gold.")
	assert(dungeon.completion_equipment_source != null, "Abandoned Iron Mines must define one completion equipment source.")
	assert(dungeon.completion_equipment_source.item_level == 10, "The first dungeon completion item must be ilvl 10.")
	assert(dungeon.completion_equipment_source.rare_items.size() == 12, "The first dungeon completion pool must cover all twelve current equipment slots including Belt.")
	assert(is_equal_approx(dungeon.completion_epic_chance, 0.25), "The first dungeon completion reward must use 75% Rare / 25% Epic rarity odds.")

	var second_dungeon = load(SECOND_DUNGEON_PATH)
	assert(second_dungeon != null, "The second Starting Region dungeon definition must exist.")
	assert(second_dungeon.id == "blackfang_settlement", "The second dungeon must keep its stable id.")
	assert(second_dungeon.display_name == "Городище Черноклыков", "The second dungeon must keep its approved name.")
	assert(second_dungeon.region_id == "starting_region", "Blackfang Settlement must belong to Starting Region.")
	assert(second_dungeon.placement_allowed_terrain_ids == PackedStringArray(["forest"]), "Blackfang Settlement must be placed on forest terrain.")
	assert(second_dungeon.placement_distance_hex_min == 5 and second_dungeon.placement_distance_hex_max == 7, "Blackfang Settlement must use the authored five-to-seven-hex placement band.")
	assert(second_dungeon.ordinary_encounter_count == 3, "Blackfang Settlement must contain exactly three ordinary combat encounters before the boss.")
	assert(second_dungeon.ordinary_mob_definition != null and second_dungeon.ordinary_mob_definition.id == "blackfang_guard", "All three ordinary encounters must use the Blackfang Guard.")
	var second_ordinary_power: float = second_dungeon.ordinary_mob_definition.get_power()
	assert(second_ordinary_power >= 595.0 and second_ordinary_power <= 605.0, "Blackfang Guard Power must remain approximately 600; got %.2f." % second_ordinary_power)
	assert(second_dungeon.ordinary_mob_definition.experience_reward == 260, "Blackfang Guard must grant 260 normal combat XP.")
	assert(second_dungeon.ordinary_mob_definition.gold_reward == 0 and second_dungeon.ordinary_mob_definition.equipment_drop_table == null, "Blackfang Guards must not grant per-mob Gold or ordinary equipment drops inside the dungeon.")
	assert(second_dungeon.boss_mob_definition != null and second_dungeon.boss_mob_definition.id == "goblin_king", "Blackfang Settlement must end with the unique Goblin King boss.")
	var second_boss_power: float = second_dungeon.boss_mob_definition.get_power()
	assert(second_boss_power >= 745.0 and second_boss_power <= 755.0, "Goblin King Power must remain approximately 750; got %.2f." % second_boss_power)
	assert(second_dungeon.boss_mob_definition.experience_reward == 320, "Goblin King must grant 320 normal combat XP.")
	assert(second_dungeon.boss_mob_definition.gold_reward == 0 and second_dungeon.boss_mob_definition.equipment_drop_table == null, "Goblin King combat must not grant per-mob Gold or ordinary equipment drops before the completion reward.")
	assert(second_dungeon.completion_gold_reward == 2000, "Blackfang Settlement completion must grant exactly 2000 Gold.")
	assert(second_dungeon.completion_equipment_source != null and second_dungeon.completion_equipment_source.item_level == 20, "Blackfang Settlement completion item must be ilvl 20.")
	assert(second_dungeon.completion_equipment_source.rare_items.size() == 12, "Blackfang Settlement completion pool must cover all twelve current ilvl 20 equipment slots.")
	assert(is_equal_approx(second_dungeon.completion_epic_chance, 0.25), "Blackfang Settlement completion reward must use 75% Rare / 25% Epic rarity odds.")

	print("PASS: DungeonSystem auto-loads both Starting Region dungeons with their approved mobs, bosses, Power/XP tuning, placement, and Rare/Epic completion rewards.")
	quit()
