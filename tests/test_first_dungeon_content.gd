extends SceneTree

const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"

func _init() -> void:
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
	assert(dungeon.completion_equipment_source.rare_items.size() == 11, "The first dungeon completion pool must cover all current non-Belt equipment slots.")
	assert(is_equal_approx(dungeon.completion_epic_chance, 0.25), "The first dungeon completion reward must use 75% Rare / 25% Epic rarity odds.")

	print("PASS: Abandoned Iron Mines defines 3 Mine Troglodytes, the Deep Devourer, and a 700 Gold + ilvl 10 Rare/Epic completion reward.")
	quit()
