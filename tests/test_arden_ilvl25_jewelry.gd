extends SceneTree

const FAMILY_DIRECTORY := "res://data/items/visual_families/gilded_wyrm"
const SHOP_BAND_PATH := "res://data/shops/bands/arden_ilvl25.tres"
const DROP_TABLE_PATH := "res://data/loot/gilded_wyrm_ilvl25_drop_table.tres"
const DUNGEON_PATH := "res://data/dungeons/mid_region/0003_iron_fang_fortress.tres"
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const ITEMS := [
	{"stem": "gilded_wyrm_pendant", "name": "Подвеска Златого Дракона", "slot": "necklace", "icon": "necklace"},
	{"stem": "gilded_wyrm_earrings", "name": "Серьги Златого Дракона", "slot": "earrings", "icon": "earrings"},
	{"stem": "gilded_wyrm_signet_ring_1", "name": "Печать Златого Дракона", "slot": "ring_1", "icon": "ring"},
	{"stem": "gilded_wyrm_signet_ring_2", "name": "Печать Златого Дракона", "slot": "ring_2", "icon": "ring"},
	{"stem": "gilded_wyrm_belt", "name": "Пояс Златого Дракона", "slot": "belt", "icon": "belt"},
]
const EXPECTED_RAW_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "necklace", "earrings", "ring_1", "ring_2", "belt", "weapon", "shield", "weapon"]

class FixedRng:
	func randf() -> float:
		return 0.5
	func randi_range(from: int, _to: int) -> int:
		return from

func _init() -> void:
	var definitions_by_quality := [[], [], []]
	for expected in ITEMS:
		for quality in RARITY_SUFFIXES.size():
			var path: String = "%s/%s%s.tres" % [FAMILY_DIRECTORY, expected.stem, RARITY_SUFFIXES[quality]]
			assert(ResourceLoader.exists(path), "Missing ilvl25 Gilded jewelry resource: %s" % path)
			var definition: Resource = load(path)
			assert(definition.id == expected.stem + RARITY_SUFFIXES[quality], "Gilded jewelry ids must match their resource stems.")
			assert(definition.display_name == expected.name and definition.equipment_slot == expected.slot and int(definition.quality) == quality, "Gilded jewelry must preserve approved name, slot, and rarity.")
			assert(definition.icon_texture != null and definition.icon_texture.resource_path == "res://assets/items/icons/gilded_wyrm/gilded_wyrm_%s.png" % expected.icon, "Gilded jewelry must use its exact supplied icon.")
			assert(definition.icon_texture.get_size() == Vector2(300.0, 300.0) and definition.hero_overlay_texture == null, "Gilded jewelry icons must remain 300x300 and icon-only.")
			definitions_by_quality[quality].append(definition)

	var generator = load("res://scripts/items/item_generator.gd").new()
	var belt_rules = load("res://scripts/items/belt_potion_rules.gd").new()
	for definition in definitions_by_quality[0]:
		var item = generator.generate(definition, 25, FixedRng.new())
		if definition.equipment_slot == "belt":
			assert(is_equal_approx(item.get_stat_bonus("max_hp"), 110.0), "ilvl25 belt must use +110 base Health.")
			assert(belt_rules.get_capacity(item) == 1 and belt_rules.get_max_potion_level(item) == 25, "Common ilvl25 belt must hold one potion up to level 25.")
		else:
			assert(item.base_stats.size() == 1 and is_equal_approx(item.get_stat_bonus("fire_resistance"), 22.0), "Each ilvl25 jewelry slot must roll exactly one +22 inherent resistance.")
	var rare_belt = generator.generate(definitions_by_quality[2][4], 25, FixedRng.new(), 2)
	assert(belt_rules.get_capacity(rare_belt) == 3 and belt_rules.get_max_potion_level(rare_belt) == 25, "Rare ilvl25 belt must hold three potions up to level 25.")

	var shop_band: Resource = load(SHOP_BAND_PATH)
	var drop_table: Resource = load(DROP_TABLE_PATH)
	var dungeon: Resource = load(DUNGEON_PATH)
	assert(shop_band.item_level == 25 and shop_band.white_listings == 5 and shop_band.uncommon_listings == 2, "Arden ilvl25 storefront counts must remain 5 White + 2 Green.")
	assert(dungeon.completion_equipment_source == drop_table, "Iron Fang Fortress must reward from the Gilded ilvl25 table.")
	for quality in RARITY_SUFFIXES.size():
		var pool: Array = [drop_table.common_items, drop_table.uncommon_items, drop_table.rare_items][quality]
		assert(pool.map(func(definition): return definition.equipment_slot) == EXPECTED_RAW_SLOTS, "Every Gilded rarity pool must include all accessory slots before weapon, shield, and Slayer two-hander.")
		for definition in definitions_by_quality[quality]:
			assert(pool.has(definition), "Every Gilded jewelry rarity must be available from ordinary mob/dungeon sources.")
			if quality < 2:
				assert(shop_band.item_definitions.has(definition), "Common/Uncommon Gilded jewelry must be eligible for Arden shop stock.")

	print("PASS: ilvl25 Gilded jewelry and Belt use supplied icons, approved inherent stats, and shared Arden shop/mob/dungeon sources.")
	quit()
