extends SceneTree

const QUALITY_SUFFIXES := ["", "_uncommon", "_rare"]
const EXPECTED_STATS := [
	[20.0, 10, 1, 4.636106690],
	[25.0, 15, 2, 7.104690214],
	[35.0, 20, 3, 10.184143277],
]
const ITEM_FAMILIES := {
	"helmet": "boar_helmet",
	"gloves": "boar_gauntlets",
	"pants": "boar_leggings",
	"boots": "boar_boots",
}
const QUEST_REWARDS := {
	"res://data/quests/0002_wolf_hunt.tres": "helmet",
	"res://data/quests/0003_bear_hunt.tres": "gloves",
	"res://data/quests/0004_granary_rat_problem.tres": "pants",
	"res://data/quests/0006_trade_road_ambush.tres": "boots",
}

func _init() -> void:
	var rare_definitions: Dictionary = {}
	for slot_id in ITEM_FAMILIES:
		var family_name: String = ITEM_FAMILIES[slot_id]
		for quality in 3:
			var item_path := "res://data/items/visual_families/ironward_vanguard/%s%s.tres" % [family_name, QUALITY_SUFFIXES[quality]]
			var definition: Resource = load(item_path)
			assert(definition != null, "Every Boar set quality definition must load: %s" % item_path)
			assert(definition.equipment_slot == slot_id, "Item definition must target its own armor slot.")
			assert(definition.quality == quality, "Item definition quality must match its resource variant.")
			assert(is_equal_approx(definition.max_hp_bonus, EXPECTED_STATS[quality][0]), "Quality MaxHP must match the Boar chestplate progression.")
			assert(definition.armor_bonus == EXPECTED_STATS[quality][1], "Quality Armor must match the Boar chestplate progression.")
			assert(definition.strength_bonus == EXPECTED_STATS[quality][2], "Quality Strength must match the Boar chestplate progression.")
			assert(is_equal_approx(definition.get_item_power(), EXPECTED_STATS[quality][3]), "Every armor piece must use universal ItemPower.")
			assert(definition.icon_texture != null, "Every temporary armor item must have an icon.")
			assert(definition.hero_overlay_texture != null, "Every visible armor piece must provide a paper-doll overlay.")
			assert(definition.hero_overlay_texture.get_width() == 441 and definition.hero_overlay_texture.get_height() == 800, "Every armor overlay must preserve the hero portrait canvas.")
			if quality == 2:
				rare_definitions[slot_id] = definition

	for quest_path in QUEST_REWARDS:
		var quest: Resource = load(quest_path)
		assert(quest != null and quest.item_reward_pool.size() == 3, "Each selected quest must expose three equal-quality rewards.")
		for quality in 3:
			assert(quest.item_reward_pool[quality].equipment_slot == QUEST_REWARDS[quest_path], "Quest reward pool must contain the assigned armor slot.")
			assert(quest.item_reward_pool[quality].quality == quality, "Quest reward pool must be ordered Common/Uncommon/Rare.")

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	var rare_chest: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres")
	simulation.receive_item_reward(rare_chest, 1)
	for slot_id in rare_definitions:
		simulation.receive_item_reward(rare_definitions[slot_id], 2)
	for slot_id in ["chest", "helmet", "gloves", "pants", "boots"]:
		assert(simulation.hero_state.equipment.get_item(slot_id) != null, "Full Boar armor set must occupy all five armor slots.")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, 360.0), "Five rare pieces must combine direct HP and Strength-derived HP.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, 22.0), "Five rare pieces must combine Strength-derived Attack.")
	assert(is_equal_approx(simulation.base_combat_stats.damage_reduction, 0.50), "Five rare pieces must combine to 100 Armor and 50 percent reduction.")

	print("PASS: Four new Boar armor families have three qualities, quest rewards, and combined stats.")
	quit()
