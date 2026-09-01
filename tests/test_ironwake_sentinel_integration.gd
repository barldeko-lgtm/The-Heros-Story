extends SceneTree

const FAMILY_DIRECTORY := "res://data/items/visual_families/ironwake_sentinel"
const DROP_TABLE_PATH := "res://data/loot/ironwake_sentinel_ilvl1_drop_table.tres"
const SHOP_PATH := "res://data/shops/starting_city_shop.tres"
const IRONWARD_DROP_TABLE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
const SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield"]
const FILE_NAMES := {
	"helmet": "ironwake_sentinel_helmet",
	"chest": "ironwake_sentinel_chestplate",
	"gloves": "ironwake_sentinel_gauntlets",
	"pants": "ironwake_sentinel_leggings",
	"boots": "ironwake_sentinel_boots",
	"weapon": "ironwake_sentinel_sword",
	"shield": "ironwake_sentinel_shield",
}
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const WEAK_MOB_IDS := ["goblin", "giant_rat", "wild_boar", "wolf", "bandit"]

func _init() -> void:
	var definitions_by_quality: Array = [[], [], []]
	for quality in 3:
		for slot in SLOTS:
			var definition_path: String = "%s/%s%s.tres" % [FAMILY_DIRECTORY, FILE_NAMES[slot], RARITY_SUFFIXES[quality]]
			var definition: Resource = load(definition_path)
			if definition == null:
				fail("Ironwake Sentinel definition must load: %s" % definition_path)
				return
			assert(definition.id.begins_with("ironwake_sentinel_"), "Every new item id must use the corrected Ironwake Sentinel family id.")
			assert(definition.display_name.contains("Стража Железного Следа"), "Every new item must use the approved Russian family name.")
			assert(definition.equipment_slot == slot, "Every Ironwake Sentinel definition must keep its mapped equipment slot.")
			assert(definition.quality == quality, "Every Ironwake Sentinel definition must keep its mapped rarity.")
			assert(definition.icon_texture != null, "Every new item must remain visible in inventory, including temporary sword/shield placeholders.")
			if slot in ["helmet", "chest", "gloves", "pants", "boots"]:
				assert(definition.hero_overlay_texture != null, "Every supplied armor piece must provide its hero overlay.")
			else:
				assert(definition.hero_overlay_texture == null, "Sword and shield must remain without hero overlays for this slice.")
			definitions_by_quality[quality].append(definition)

	var drop_table: Resource = load(DROP_TABLE_PATH)
	if drop_table == null:
		fail("Ironwake Sentinel ilvl 1 drop table must exist.")
		return
	assert(is_equal_approx(drop_table.drop_chance, 0.05), "The new family must preserve the existing 5% equipment-drop chance.")
	assert(drop_table.item_level == 1, "The new family drop source must generate ilvl 1 items.")
	assert(drop_table.common_items == definitions_by_quality[0], "The new drop table must expose all seven White family definitions in slot order.")
	assert(drop_table.uncommon_items == definitions_by_quality[1], "The new drop table must expose all seven Green family definitions in slot order.")
	assert(drop_table.rare_items == definitions_by_quality[2], "The new drop table must expose all seven Blue family definitions in slot order.")

	var ironward_drop_table: Resource = load(IRONWARD_DROP_TABLE_PATH)
	assert(ironward_drop_table != null, "The existing Ironward Vanguard drop table must remain available.")
	var weak_count := 0
	var strong_count := 0
	for file_name in DirAccess.get_files_at("res://data/mobs"):
		if not file_name.ends_with(".tres"):
			continue
		var mob: Resource = load("res://data/mobs/%s" % file_name)
		assert(mob != null, "Every current mob must still load after source reassignment.")
		if WEAK_MOB_IDS.has(mob.id):
			weak_count += 1
			assert(mob.equipment_drop_table == drop_table, "Each selected weak mob must use the Ironwake Sentinel ilvl 1 source: %s" % mob.id)
		else:
			strong_count += 1
			assert(mob.equipment_drop_table == ironward_drop_table, "Each remaining mob must keep the Ironward Vanguard ilvl 10 source: %s" % mob.id)
	assert(weak_count == 5 and strong_count == 10, "The 15 mobs must split into five weaker and ten stronger equipment sources.")

	var shop_definition: Resource = load(SHOP_PATH)
	assert(shop_definition != null, "Starting City shop definition must load.")
	assert(shop_definition.stock_bands.size() == 2, "Starting City shop must contain separate ilvl 1 and ilvl 10 stock bands.")
	assert(shop_definition.stock_bands[0].item_level == 1, "The first shop band must sell Ironwake Sentinel at ilvl 1.")
	assert(shop_definition.stock_bands[1].item_level == 10, "The second shop band must retain Ironward Vanguard at ilvl 10.")

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(2718)
	var listings: Array = simulation.shop_system.get_listings()
	assert(listings.size() == 16, "Two shop bands must generate 8 listings each.")
	assert_shop_band(listings, 1, "ironwake_sentinel")
	assert_shop_band(listings, 10, "ironward_vanguard")

	print("PASS: Ironwake Sentinel integrates 21 items, ilvl 1 weak-mob drops, hero overlays, and a separate Starting City shop band.")
	quit()

func assert_shop_band(listings: Array, item_level: int, family_path_part: String) -> void:
	var rarity_counts := {0: 0, 1: 0}
	var slots_by_rarity := {0: [], 1: []}
	for listing in listings:
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.item_level != item_level:
			continue
		assert(item_instance.definition.resource_path.contains(family_path_part), "Each shop band must use only its assigned visual family.")
		assert(item_instance.rarity in [0, 1], "Normal shop stock must remain White/Green only.")
		rarity_counts[item_instance.rarity] += 1
		var slot: String = item_instance.definition.equipment_slot
		assert(not slots_by_rarity[item_instance.rarity].has(slot), "Each shop band/rarity must keep unique equipment slots.")
		slots_by_rarity[item_instance.rarity].append(slot)
	assert(rarity_counts[0] == 6, "Each shop band must contain six White listings.")
	assert(rarity_counts[1] == 2, "Each shop band must contain two Green listings.")

func fail(message: String) -> void:
	push_error(message)
	quit(1)
