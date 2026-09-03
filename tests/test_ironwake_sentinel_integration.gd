extends SceneTree

const FAMILY_DIRECTORY := "res://data/items/visual_families/rustchain_initiate"
const DROP_TABLE_PATH := "res://data/loot/ironwake_sentinel_ilvl1_drop_table.tres"
const SHOP_PATH := "res://data/shops/starting_city_shop.tres"
const ILVL10_SOURCE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
const ILVL20_SOURCE_PATH := "res://data/loot/ironward_vanguard_ilvl20_drop_table.tres"
const SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield"]
const FILE_NAMES := {
	"helmet": "rustchain_initiate_helmet",
	"chest": "rustchain_initiate_chestplate",
	"gloves": "rustchain_initiate_gauntlets",
	"pants": "rustchain_initiate_leggings",
	"boots": "rustchain_initiate_boots",
	"weapon": "rustchain_initiate_sword",
	"shield": "rustchain_initiate_shield",
}
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const WEAK_MOB_IDS := ["goblin", "giant_rat", "wild_boar", "wolf", "bandit"]
const MID_MOB_IDS := ["giant_spider", "bear", "rabid_elk", "bandit_veteran", "swamp_crocodile"]

func _init() -> void:
	var definitions_by_quality: Array = [[], [], []]
	for quality in 3:
		for slot in SLOTS:
			var definition_path: String = "%s/%s%s.tres" % [FAMILY_DIRECTORY, FILE_NAMES[slot], RARITY_SUFFIXES[quality]]
			var definition: Resource = load(definition_path)
			if definition == null:
				fail("Rustchain Initiate definition must load: %s" % definition_path)
				return
			assert(definition.id.begins_with("rustchain_initiate_"), "Every new item id must use the Rustchain Initiate family id.")
			assert(definition.display_name.contains("Посвящённого Ржавой Цепи"), "Every new item must use the approved Russian family name.")
			assert(definition.equipment_slot == slot, "Every Rustchain Initiate definition must keep its mapped equipment slot.")
			assert(definition.quality == quality, "Every Rustchain Initiate definition must keep its mapped rarity.")
			assert(definition.icon_texture != null, "Every new item must remain visible in inventory, including temporary sword/shield placeholders.")
			if slot in ["helmet", "chest", "gloves", "pants", "boots"]:
				assert(definition.hero_overlay_texture != null, "Every supplied armor piece must provide its hero overlay.")
			else:
				assert(definition.hero_overlay_texture == null, "Sword and shield must remain without hero overlays for this slice.")
			definitions_by_quality[quality].append(definition)

	var drop_table: Resource = load(DROP_TABLE_PATH)
	if drop_table == null:
		fail("The existing ilvl 1 drop table must remain available for Rustchain Initiate.")
		return
	assert(is_equal_approx(drop_table.drop_chance, 0.05), "The new family must preserve the existing 5% equipment-drop chance.")
	assert(drop_table.item_level == 1, "The new family drop source must generate ilvl 1 items.")
	assert(drop_table.common_items == definitions_by_quality[0], "The new drop table must expose all seven White family definitions in slot order.")
	assert(drop_table.uncommon_items == definitions_by_quality[1], "The new drop table must expose all seven Green family definitions in slot order.")
	assert(drop_table.rare_items == definitions_by_quality[2], "The new drop table must expose all seven Blue family definitions in slot order.")

	var ilvl10_drop_table := load(ILVL10_SOURCE_PATH)
	var ilvl20_drop_table := load(ILVL20_SOURCE_PATH)
	assert(ilvl10_drop_table != null, "The existing full ilvl 10 drop table must remain available.")
	assert(ilvl20_drop_table != null, "The new seven-slot ilvl 20 drop table must be available.")
	var weak_count := 0
	var mid_count := 0
	var strong_count := 0
	for file_name in DirAccess.get_files_at("res://data/mobs"):
		if not file_name.ends_with(".tres"):
			continue
		var mob: Resource = load("res://data/mobs/%s" % file_name)
		assert(mob != null, "Every current mob must still load after source reassignment.")
		if WEAK_MOB_IDS.has(mob.id):
			weak_count += 1
			assert(mob.equipment_drop_table == drop_table, "Each selected weak mob must use the Rustchain Initiate ilvl 1 source: %s" % mob.id)
		elif MID_MOB_IDS.has(mob.id):
			mid_count += 1
			assert(mob.equipment_drop_table == ilvl10_drop_table, "Each middle-tier mob must use the full ilvl 10 source: %s" % mob.id)
		else:
			strong_count += 1
			assert(mob.equipment_drop_table == ilvl20_drop_table, "Each strongest mob must use the Ironward ilvl 20 source: %s" % mob.id)
	assert(weak_count == 5 and mid_count == 5 and strong_count == 5, "The 15 mobs must split evenly across ilvl 1/10/20 equipment sources.")

	var shop_definition: Resource = load(SHOP_PATH)
	assert(shop_definition != null, "Starting City shop definition must load.")
	assert(shop_definition.stock_bands.size() == 3, "Starting City shop must contain separate ilvl 1, 10, and 20 stock bands.")
	assert(shop_definition.stock_bands[0].item_level == 1, "The first shop band must retain ilvl 1 while using Rustchain Initiate.")
	assert(shop_definition.stock_bands[1].item_level == 10, "The second shop band must retain ilvl 10 while using Ironwake core visuals.")
	assert(shop_definition.stock_bands[2].item_level == 20, "The third shop band must use Ironward Vanguard at ilvl 20.")

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(2718)
	var listings: Array = simulation.shop_system.get_listings()
	assert(listings.size() == 24, "Three shop bands must generate 8 listings each.")
	assert_shop_band(listings, 1)
	assert_shop_band(listings, 10)
	assert_shop_band(listings, 20)

	print("PASS: Rustchain, Ironwake, and Ironward integrate across live ilvl 1/10/20 drops and shop bands.")
	quit()

func assert_shop_band(listings: Array, item_level: int) -> void:
	var rarity_counts := {0: 0, 1: 0}
	var slots_by_rarity := {0: [], 1: []}
	for listing in listings:
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.item_level != item_level:
			continue
		var slot: String = item_instance.definition.equipment_slot
		if item_level == 1:
			assert(item_instance.definition.resource_path.contains("rustchain_initiate"), "The ilvl 1 shop band must use Rustchain Initiate.")
		elif item_level == 20:
			assert(item_instance.definition.resource_path.contains("ironward_vanguard/boar_"), "The ilvl 20 shop band must use Ironward Vanguard core equipment.")
		elif slot in SLOTS:
			assert(item_instance.definition.resource_path.contains("ironwake_sentinel"), "Core ilvl 10 shop slots must use Ironwake Sentinel.")
		else:
			assert(item_instance.definition.resource_path.contains("ironward_vanguard/ironward_"), "Existing ilvl 10 accessory definitions must remain unchanged.")
		assert(item_instance.rarity in [0, 1], "Normal shop stock must remain White/Green only.")
		rarity_counts[item_instance.rarity] += 1
		assert(not slots_by_rarity[item_instance.rarity].has(slot), "Each shop band/rarity must keep unique equipment slots.")
		slots_by_rarity[item_instance.rarity].append(slot)
	assert(rarity_counts[0] == 6, "Each shop band must contain six White listings.")
	assert(rarity_counts[1] == 2, "Each shop band must contain two Green listings.")

func fail(message: String) -> void:
	push_error(message)
	quit(1)
