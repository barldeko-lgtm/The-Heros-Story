extends SceneTree

const SHOP_PATH := "res://data/shops/arden_shop.tres"
const BAND_PATHS := [
	"res://data/shops/bands/arden_ilvl15.tres",
	"res://data/shops/bands/arden_ilvl20.tres",
	"res://data/shops/bands/arden_ilvl25.tres",
]
const EXPECTED_BANDS := [
	{"item_level": 15, "white_listings": 6, "slots": ["helmet", "chest", "gloves", "pants", "boots", "necklace", "earrings", "ring_1", "ring_2", "belt"], "white_price": 1350, "uncommon_price": 4050},
	{"item_level": 20, "white_listings": 5, "slots": ["helmet", "chest", "gloves", "pants", "boots"], "white_price": 2300, "uncommon_price": 6900},
	{"item_level": 25, "white_listings": 5, "slots": ["helmet", "chest", "gloves", "pants", "boots"], "white_price": 3600, "uncommon_price": 10800},
]
const EXPECTED_DEFINITIONS := [
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawnplate_helmet.tres", "id": "azure_dawnplate_helmet", "name": "Шлем Лазурной Зари", "slot": "helmet", "overlay": true},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawnplate_cuirass.tres", "id": "azure_dawnplate_cuirass", "name": "Кираса Лазурной Зари", "slot": "chest", "overlay": true},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawnplate_gauntlets.tres", "id": "azure_dawnplate_gauntlets", "name": "Рукавицы Лазурной Зари", "slot": "gloves", "overlay": true},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawnplate_legguards.tres", "id": "azure_dawnplate_legguards", "name": "Поножи Лазурной Зари", "slot": "pants", "overlay": true},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawnplate_sabatons.tres", "id": "azure_dawnplate_sabatons", "name": "Сабатоны Лазурной Зари", "slot": "boots", "overlay": true},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawn_signet_ring_1.tres", "id": "azure_dawn_signet_ring_1", "name": "Печать Лазурной Зари", "slot": "ring_1", "overlay": false},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawn_signet_ring_2.tres", "id": "azure_dawn_signet_ring_2", "name": "Печать Лазурной Зари", "slot": "ring_2", "overlay": false},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawn_belt.tres", "id": "azure_dawn_belt", "name": "Пояс Лазурной Зари", "slot": "belt", "overlay": false},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawn_earrings.tres", "id": "azure_dawn_earrings", "name": "Серьги Лазурной Зари", "slot": "earrings", "overlay": false},
	{"path": "res://data/items/visual_families/azure_dawnplate/azure_dawn_pendant.tres", "id": "azure_dawn_pendant", "name": "Подвеска Лазурной Зари", "slot": "necklace", "overlay": false},
	{"path": "res://data/items/visual_families/crimson_thornplate/crimson_thornplate_helmet.tres", "id": "crimson_thornplate_helmet", "name": "Шлем Багрового Шипа", "slot": "helmet", "overlay": false},
	{"path": "res://data/items/visual_families/crimson_thornplate/crimson_thornplate_cuirass.tres", "id": "crimson_thornplate_cuirass", "name": "Кираса Багрового Шипа", "slot": "chest", "overlay": false},
	{"path": "res://data/items/visual_families/crimson_thornplate/crimson_thornplate_gauntlets.tres", "id": "crimson_thornplate_gauntlets", "name": "Рукавицы Багрового Шипа", "slot": "gloves", "overlay": false},
	{"path": "res://data/items/visual_families/crimson_thornplate/crimson_thornplate_legguards.tres", "id": "crimson_thornplate_legguards", "name": "Поножи Багрового Шипа", "slot": "pants", "overlay": false},
	{"path": "res://data/items/visual_families/crimson_thornplate/crimson_thornplate_sabatons.tres", "id": "crimson_thornplate_sabatons", "name": "Сабатоны Багрового Шипа", "slot": "boots", "overlay": false},
	{"path": "res://data/items/visual_families/gilded_wyrm/gilded_wyrm_helmet.tres", "id": "gilded_wyrm_helmet", "name": "Шлем Златого Дракона", "slot": "helmet", "overlay": false},
	{"path": "res://data/items/visual_families/gilded_wyrm/gilded_wyrm_cuirass.tres", "id": "gilded_wyrm_cuirass", "name": "Кираса Златого Дракона", "slot": "chest", "overlay": false},
	{"path": "res://data/items/visual_families/gilded_wyrm/gilded_wyrm_gauntlets.tres", "id": "gilded_wyrm_gauntlets", "name": "Рукавицы Златого Дракона", "slot": "gloves", "overlay": false},
	{"path": "res://data/items/visual_families/gilded_wyrm/gilded_wyrm_legguards.tres", "id": "gilded_wyrm_legguards", "name": "Поножи Златого Дракона", "slot": "pants", "overlay": false},
	{"path": "res://data/items/visual_families/gilded_wyrm/gilded_wyrm_sabatons.tres", "id": "gilded_wyrm_sabatons", "name": "Сабатоны Златого Дракона", "slot": "boots", "overlay": false},
]

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	assert_definition_resources()
	var shop: Resource = load(SHOP_PATH)
	assert(shop != null, "Arden shop resource must exist.")
	assert(shop.id == "arden_shop" and shop.city_id == "mid_city", "Arden shop must belong to Mid City.")
	assert(shop.refresh_interval_ticks == 200, "Arden shop must preserve the Starting City 200-tick refresh interval.")
	assert(shop.healing_potion_definitions.size() == 2, "Arden shop must preserve both Starting City potion definitions.")
	assert(shop.healing_potion_definitions[0].potion_level == 5 and shop.healing_potion_definitions[0].shop_price == 100, "Arden must retain the Level 5 / 100 Gold potion.")
	assert(shop.healing_potion_definitions[1].potion_level == 10 and shop.healing_potion_definitions[1].shop_price == 200, "Arden must retain the Level 10 / 200 Gold potion.")
	assert(shop.stock_bands.size() == 3, "Arden shop must expose exactly ilvl 15, 20, and 25 bands.")
	for index in EXPECTED_BANDS.size():
		assert_band(shop.stock_bands[index], EXPECTED_BANDS[index], BAND_PATHS[index])
	assert_generated_stock(shop)
	print("PASS: Arden uses only the supplied Azure Dawnplate, Crimson Thornplate, and Gilded Wyrm visuals in exact Common/Uncommon shop content.")
	quit()

func assert_definition_resources() -> void:
	assert_definition_file_sets()
	for expected in EXPECTED_DEFINITIONS:
		for suffix in ["", "_uncommon"]:
			var resource_path: String = expected.path.replace(".tres", "%s.tres" % suffix)
			var definition: Resource = load(resource_path)
			assert(definition != null, "Required Arden item definition is missing: %s" % resource_path)
			assert(definition.id == "%s%s" % [expected.id, suffix], "Item id must be exact: %s" % resource_path)
			assert(definition.display_name == expected.name and definition.equipment_slot == expected.slot, "Item name and slot must be exact: %s" % resource_path)
			assert(int(definition.quality) == (1 if suffix == "_uncommon" else 0), "Only Common and Uncommon definitions are allowed: %s" % resource_path)
			assert(definition.icon_texture != null, "Every supplied finished visual must have its icon: %s" % resource_path)
			var family: String = expected.path.get_base_dir().get_file()
			var icon_asset: String = "chestplate" if expected.slot == "chest" else ("gauntlets" if expected.slot == "gloves" else ("pants" if expected.slot == "pants" else ("boots" if expected.slot == "boots" else ("necklace" if expected.slot == "necklace" else ("ring" if expected.slot.begins_with("ring_") else expected.slot)))))
			var expected_icon_path := "res://assets/items/icons/%s/%s_%s.png" % [family, family, icon_asset]
			assert(definition.icon_texture.resource_path == expected_icon_path, "Arden definitions must use their exact supplied icon, without placeholder reuse: %s" % resource_path)
			if expected.overlay:
				assert(definition.hero_overlay_texture != null, "Only Azure ilvl 15 armor must have supplied overlays: %s" % resource_path)
				assert(definition.hero_overlay_texture.get_width() == 441 and definition.hero_overlay_texture.get_height() == 800, "Azure ilvl 15 armor overlays must be 441x800: %s" % resource_path)
			else:
				assert(definition.hero_overlay_texture == null, "Jewelry and ilvl 20/25 armor must not invent overlays: %s" % resource_path)

func assert_definition_file_sets() -> void:
	var expected_by_family := {"azure_dawnplate": 10, "crimson_thornplate": 5, "gilded_wyrm": 5}
	for family in expected_by_family:
		var directory_path := "res://data/items/visual_families/%s" % family
		var actual_files := DirAccess.get_files_at(directory_path)
		var expected_files: Array[String] = []
		for expected in EXPECTED_DEFINITIONS:
			if expected.path.get_base_dir().get_file() != family:
				continue
			expected_files.append(expected.path.get_file())
			expected_files.append(expected.path.get_file().replace(".tres", "_uncommon.tres"))
		assert(actual_files.size() == int(expected_by_family[family]) * 2, "Arden visual family must contain exactly its Common and Uncommon supplied-visual resources, with no Rare or placeholder files.")
		for resource_file in actual_files:
			assert(expected_files.has(resource_file), "Arden visual family must not contain an unapproved resource: %s/%s" % [family, resource_file])

func assert_band(band: Resource, expected: Dictionary, expected_path: String) -> void:
	assert(band != null and band.resource_path == expected_path, "Arden stock band must load from its exact resource path.")
	assert(band.item_level == expected.item_level and band.white_listings == expected.white_listings and band.uncommon_listings == 2, "Every Arden band must have exact ilvl and approved White / 2 Green listings.")
	var definitions_by_rarity := {0: [], 1: []}
	for definition in band.item_definitions:
		assert(definition != null and int(definition.quality) in [0, 1], "Arden bands must contain no Rare resources.")
		definitions_by_rarity[int(definition.quality)].append(definition)
	for rarity in [0, 1]:
		var definitions: Array = definitions_by_rarity[rarity]
		assert(definitions.size() == expected.slots.size(), "Each Arden rarity pool must cover every allowed slot exactly once.")
		var slots: Array[String] = []
		for definition in definitions:
			assert(not slots.has(definition.equipment_slot), "Each Arden rarity pool must not duplicate an equipment slot.")
			slots.append(definition.equipment_slot)
		assert(slots == expected.slots, "Each Arden rarity pool must use the approved slot order and no missing visuals.")

func assert_generated_stock(shop: Resource) -> void:
	var shop_system_script: Script = load("res://scripts/economy/shop_system.gd")
	var item_generator_script: Script = load("res://scripts/items/item_generator.gd")
	var price_calculator = load("res://scripts/economy/item_price_calculator.gd").new()
	for seed in range(1, 21):
		var system = shop_system_script.new(shop, item_generator_script.new(), seed)
		assert(system.get_listings().size() == 22, "Arden generated stock must contain 22 listings across its 6/2, 5/2, and 5/2 bands.")
		for expected in EXPECTED_BANDS:
			for rarity in [0, 1]:
				var expected_count: int = expected.white_listings if rarity == 0 else 2
				var expected_price: int = expected.white_price if rarity == 0 else expected.uncommon_price
				var slots: Array[String] = []
				for listing in system.get_listings():
					var item = listing.get("item_instance")
					if item.item_level != expected.item_level or item.rarity != rarity:
						continue
					assert(not slots.has(item.definition.equipment_slot), "Generated Arden stock must not duplicate a slot within one ilvl/rarity band.")
					slots.append(item.definition.equipment_slot)
					assert(price_calculator.get_reference_shop_value_for_item(item) == expected_price, "Arden item prices must use the approved central Common/Uncommon price table.")
				assert(slots.size() == expected_count, "Generated Arden stock must preserve exact 6 White / 2 Green counts in every band.")
