extends SceneTree

const FAMILY_DIRECTORY := "res://data/items/visual_families/crimson_thornplate"
const SHOP_BAND_PATH := "res://data/shops/bands/arden_ilvl20.tres"
const DROP_TABLE_PATH := "res://data/loot/crimson_thornplate_ilvl20_drop_table.tres"
const ASH_CAVES_PATH := "res://data/dungeons/mid_region/0002_ash_caves.tres"
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const ITEMS := [
	{"stem": "crimson_thornplate_pendant", "name": "Подвеска Багрового Шипа", "slot": "necklace", "icon": "necklace"},
	{"stem": "crimson_thornplate_earrings", "name": "Серьги Багрового Шипа", "slot": "earrings", "icon": "earrings"},
	{"stem": "crimson_thornplate_signet_ring_1", "name": "Печать Багрового Шипа", "slot": "ring_1", "icon": "ring"},
	{"stem": "crimson_thornplate_signet_ring_2", "name": "Печать Багрового Шипа", "slot": "ring_2", "icon": "ring"},
	{"stem": "crimson_thornplate_belt", "name": "Пояс Багрового Шипа", "slot": "belt", "icon": "belt"},
]
const EXPECTED_RAW_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "necklace", "earrings", "ring_1", "ring_2", "belt", "weapon", "shield", "weapon"]

class FixedRng:
	func randf() -> float:
		return 0.5
	func randi_range(from: int, _to: int) -> int:
		return from

func _init() -> void:
	call_deferred("run_test")

func fail_test(message: String) -> void:
	push_error(message)
	quit(1)

func run_test() -> void:
	var definitions_by_quality := {0: [], 1: [], 2: []}
	for expected in ITEMS:
		for quality in 3:
			var path: String = "%s/%s%s.tres" % [FAMILY_DIRECTORY, expected.stem, RARITY_SUFFIXES[quality]]
			if not ResourceLoader.exists(path):
				fail_test("Missing ilvl20 Crimson jewelry definition: %s" % path)
				return
			var definition: Resource = load(path)
			assert(definition.id == expected.stem + RARITY_SUFFIXES[quality], "Crimson jewelry ids must match their resource stems.")
			assert(definition.display_name == expected.name and definition.equipment_slot == expected.slot and int(definition.quality) == quality, "Crimson jewelry must preserve approved name, slot, and rarity.")
			assert(definition.icon_texture != null and definition.icon_texture.resource_path == "res://assets/items/icons/crimson_thornplate/crimson_thornplate_%s.png" % expected.icon, "Crimson jewelry must use its exact supplied icon.")
			assert(definition.icon_texture.get_size() == Vector2(300.0, 300.0) and definition.hero_overlay_texture == null, "Crimson jewelry icons must remain 300x300 and icon-only.")
			definitions_by_quality[quality].append(definition)

	assert(definitions_by_quality[0][2].icon_texture == definitions_by_quality[0][3].icon_texture, "Both ring slots must reuse the same supplied ring icon.")
	var generator = load("res://scripts/items/item_generator.gd").new()
	var common_necklace = generator.generate(definitions_by_quality[0][0], 20, FixedRng.new())
	assert(common_necklace != null and common_necklace.base_stats.size() == 1 and is_equal_approx(common_necklace.get_stat_bonus("fire_resistance"), 18.0), "Common ilvl20 jewelry must generate exactly one inherent +18 elemental Resistance.")
	var common_belt = generator.generate(definitions_by_quality[0][4], 20, FixedRng.new())
	var rare_belt = generator.generate(definitions_by_quality[2][4], 20, FixedRng.new(), 2)
	var belt_rules = load("res://scripts/items/belt_potion_rules.gd").new()
	assert(common_belt != null and is_equal_approx(common_belt.get_stat_bonus("max_hp"), 85.0), "ilvl20 Belt must generate +85 inherent Health.")
	assert(belt_rules.get_max_potion_level(common_belt) == 20 and belt_rules.get_capacity(common_belt) == 1 and belt_rules.get_capacity(rare_belt) == 3, "ilvl20 Belt must derive potion level 20 and rarity-based capacity through shared rules.")

	var shop_band: Resource = load(SHOP_BAND_PATH)
	var drop_table: Resource = load(DROP_TABLE_PATH)
	assert(shop_band != null and drop_table != null, "Arden ilvl20 shop and drop sources must load.")
	for quality in 3:
		var drop_pool: Array = [drop_table.common_items, drop_table.uncommon_items, drop_table.rare_items][quality]
		assert(drop_pool.size() == EXPECTED_RAW_SLOTS.size(), "Every ilvl20 drop rarity must contain twelve standard slots plus the Slayer two-hander.")
		for index in EXPECTED_RAW_SLOTS.size():
			assert(drop_pool[index].equipment_slot == EXPECTED_RAW_SLOTS[index], "ilvl20 drop rarity pools must keep the approved aligned slot order.")
		for definition in definitions_by_quality[quality]:
			assert(drop_pool.has(definition), "Every ilvl20 jewelry rarity must be connected to the matching drop pool.")
		if quality < 2:
			for definition in definitions_by_quality[quality]:
				assert(shop_band.item_definitions.has(definition), "Common/Uncommon ilvl20 jewelry must be connected to Arden shop stock.")

	var ash_caves: Resource = load(ASH_CAVES_PATH)
	assert(ash_caves != null and ash_caves.completion_equipment_source == drop_table, "Ash Caves must use the expanded ilvl20 source for its completion reward.")
	print("PASS: ilvl20 Crimson jewelry and Belt use supplied icons, approved inherent stats, and shared Arden shop/mob/dungeon sources.")
	quit()
