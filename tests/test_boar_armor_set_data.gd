extends SceneTree

const QUALITY_SUFFIXES := ["", "_uncommon", "_rare"]
const ITEM_FAMILIES := {
	"helmet": "boar_helmet",
	"gloves": "boar_gauntlets",
	"pants": "boar_leggings",
	"boots": "boar_boots",
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
			assert(definition.icon_texture != null, "Every temporary armor item must have an icon.")
			assert(definition.hero_overlay_texture != null, "Every visible armor piece must provide a paper-doll overlay.")
			assert(definition.hero_overlay_texture.get_width() == 441 and definition.hero_overlay_texture.get_height() == 800, "Every armor overlay must preserve the hero portrait canvas.")
			if quality == 2:
				rare_definitions[slot_id] = definition


	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	var starting_hp: float = simulation.base_combat_stats.max_hp
	var starting_attack: float = simulation.base_combat_stats.attack
	var starting_armor: float = simulation.base_combat_stats.armor
	var rare_chest: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres")
	simulation.receive_item_reward(rare_chest, 1)
	for slot_id in rare_definitions:
		simulation.receive_item_reward(rare_definitions[slot_id], 2)
	for slot_id in ["chest", "helmet", "gloves", "pants", "boots"]:
		assert(simulation.hero_state.equipment.get_item(slot_id) != null, "Full Boar armor set must occupy all five armor slots.")
	var expected_hp: float = starting_hp
	var expected_attack: float = starting_attack
	var expected_armor: float = starting_armor
	for item_instance in simulation.hero_state.equipment.get_all_items():
		assert(item_instance.item_level == 10 and item_instance.affixes.size() == 2, "Every current Rare armor piece must be a generated ilvl 10 item.")
		expected_hp += item_instance.get_stat_bonus("max_hp")
		expected_attack += item_instance.get_stat_bonus("attack")
		expected_armor += item_instance.get_stat_bonus("armor")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, expected_hp), "Generated armor Health must resolve through Equipment.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, expected_attack), "Generated armor Damage must resolve through Equipment.")
	assert(is_equal_approx(simulation.base_combat_stats.armor, expected_armor), "Generated inherent and affix Armor must resolve through Equipment.")

	print("PASS: Four Boar armor families keep their visuals and generate ilvl 10 instance stats.")
	quit()
