extends SceneTree

const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")

const RUSTCHAIN_DIRECTORY := "res://data/items/visual_families/rustchain_initiate"
const IRONWAKE_DIRECTORY := "res://data/items/visual_families/ironwake_sentinel"
const IRONWARD_DIRECTORY := "res://data/items/visual_families/ironward_vanguard"
const ILVL1_SOURCE_PATH := "res://data/loot/ironwake_sentinel_ilvl1_drop_table.tres"
const ILVL10_SOURCE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
const ILVL20_SOURCE_PATH := "res://data/loot/ironward_vanguard_ilvl20_drop_table.tres"
const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"
const SHOP_PATH := "res://data/shops/starting_city_shop.tres"
const ILVL1_MOB_IDS := ["goblin", "giant_rat", "wild_boar", "wolf", "bandit"]
const ILVL10_MOB_IDS := ["giant_spider", "bear", "rabid_elk", "bandit_veteran", "swamp_crocodile"]
const ILVL20_MOB_IDS := ["young_ogre", "cave_lizard", "forest_troll", "mountain_beast", "orc_raider"]

const SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield"]
const FILE_STEMS := {
	"helmet": "helmet",
	"chest": "chestplate",
	"gloves": "gauntlets",
	"pants": "leggings",
	"boots": "boots",
	"weapon": "sword",
	"shield": "shield",
}
const DISPLAY_NAMES := {
	"helmet": "Шлем Посвящённого Ржавой Цепи",
	"chest": "Нагрудник Посвящённого Ржавой Цепи",
	"gloves": "Рукавицы Посвящённого Ржавой Цепи",
	"pants": "Поножи Посвящённого Ржавой Цепи",
	"boots": "Сапоги Посвящённого Ржавой Цепи",
	"weapon": "Меч Посвящённого Ржавой Цепи",
	"shield": "Щит Посвящённого Ржавой Цепи",
}
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const ICON_NODES := {
	"helmet": "HelmetEquipmentIcon",
	"chest": "ChestEquipmentIcon",
	"gloves": "GlovesEquipmentIcon",
	"pants": "PantsEquipmentIcon",
	"boots": "BootsEquipmentIcon",
	"weapon": "WeaponEquipmentIcon",
	"shield": "ShieldEquipmentIcon",
}
const OVERLAY_NODES := {
	"helmet": "HeroHelmetOverlay",
	"chest": "HeroChestOverlay",
	"gloves": "HeroGlovesOverlay",
	"pants": "HeroPantsOverlay",
	"boots": "HeroBootsOverlay",
}

class NoRollRng:
	extends RefCounted

	func randf() -> float:
		return 0.5

	func randi_range(from: int, _to: int) -> int:
		return from

func _init() -> void:
	call_deferred("run_test")

func require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func run_test() -> void:
	var rustchain_by_quality: Array = [[], [], []]
	var ironwake_by_quality: Array = [[], [], []]
	var ironward_by_quality: Array = [[], [], []]
	for quality in 3:
		for slot in SLOTS:
			var suffix: String = RARITY_SUFFIXES[quality]
			var rustchain_path := "%s/rustchain_initiate_%s%s.tres" % [RUSTCHAIN_DIRECTORY, FILE_STEMS[slot], suffix]
			var ironwake_path := "%s/ironwake_sentinel_%s%s.tres" % [IRONWAKE_DIRECTORY, FILE_STEMS[slot], suffix]
			var ironward_stem: String = "boar_%s" % FILE_STEMS[slot]
			var ironward_path := "%s/%s%s.tres" % [IRONWARD_DIRECTORY, ironward_stem, suffix]
			var rustchain: Resource = load(rustchain_path)
			var ironwake: Resource = load(ironwake_path)
			var ironward: Resource = load(ironward_path)
			if not require(rustchain != null, "Rustchain Initiate definition must load: %s" % rustchain_path):
				return
			if not require(ironwake != null and ironward != null, "Shifted ilvl 10/20 core definitions must remain available."):
				return
			if not require(rustchain.id == "rustchain_initiate_%s%s" % [FILE_STEMS[slot], suffix], "Rustchain identity must match its file and rarity."):
				return
			if not require(rustchain.display_name == DISPLAY_NAMES[slot], "Rustchain item must use the approved Russian family name for %s." % slot):
				return
			if not require(rustchain.equipment_slot == slot and rustchain.quality == quality, "Rustchain slot/rarity mapping must remain aligned."):
				return
			if not require(rustchain.icon_texture != null and rustchain.icon_texture.get_size() == Vector2(300, 300), "Every Rustchain item must use a supplied 300x300 icon."):
				return
			if slot in OVERLAY_NODES:
				if not require(rustchain.hero_overlay_texture != null and rustchain.hero_overlay_texture.get_size() == Vector2(441, 800), "Every Rustchain armor piece must use a supplied 441x800 overlay."):
					return
			else:
				if not require(rustchain.hero_overlay_texture == null, "Rustchain sword/shield must remain icon-only."):
					return
			rustchain_by_quality[quality].append(rustchain)
			ironwake_by_quality[quality].append(ironwake)
			ironward_by_quality[quality].append(ironward)

	var ilvl1_source: Resource = load(ILVL1_SOURCE_PATH)
	var ilvl10_source: Resource = load(ILVL10_SOURCE_PATH)
	var ilvl20_source: Resource = load(ILVL20_SOURCE_PATH)
	var dungeon: Resource = load(DUNGEON_PATH)
	var shop: Resource = load(SHOP_PATH)
	if not require(ilvl1_source != null and ilvl10_source != null and ilvl20_source != null and dungeon != null and shop != null, "All three live equipment sources, dungeon, and shop must load."):
		return
	if not require(ilvl1_source.item_level == 1 and is_equal_approx(ilvl1_source.drop_chance, 0.05), "The weak-mob source must keep ilvl 1 and 5% drop chance."):
		return
	if not require(ilvl1_source.common_items == rustchain_by_quality[0] and ilvl1_source.uncommon_items == rustchain_by_quality[1] and ilvl1_source.rare_items == rustchain_by_quality[2], "The unchanged ilvl 1 source must now use Rustchain Initiate in all rarities."):
		return
	if not require(ilvl10_source.item_level == 10 and is_equal_approx(ilvl10_source.drop_chance, 0.05), "The stronger-mob/dungeon source must remain ilvl 10 with 5% ordinary drop chance."):
		return
	for quality in 3:
		var pool: Array = [ilvl10_source.common_items, ilvl10_source.uncommon_items, ilvl10_source.rare_items][quality]
		if not require(pool.size() == 12, "Every ilvl 10 rarity pool must keep all twelve slots."):
			return
		if not require(pool.slice(0, 7) == ironwake_by_quality[quality], "The seven core ilvl 10 slots must now use Ironwake Sentinel visuals."):
			return
		for accessory in pool.slice(7, 12):
			if not require(accessory.resource_path.contains("ironward_vanguard/ironward_"), "Existing ilvl 10 jewelry and Belt definitions must remain unchanged."):
				return
	if not require(ilvl20_source.item_level == 20 and is_equal_approx(ilvl20_source.drop_chance, 0.05), "The strongest-mob source must use ilvl 20 and the unchanged 5% drop chance."):
		return
	if not require(ilvl20_source.common_items == ironward_by_quality[0] and ilvl20_source.uncommon_items == ironward_by_quality[1] and ilvl20_source.rare_items == ironward_by_quality[2], "The ilvl 20 source must expose all seven Ironward core slots in every rarity."):
		return
	if not require(dungeon.completion_equipment_source == ilvl10_source and dungeon.completion_equipment_source.item_level == 10, "The first dungeon must keep its existing ilvl 10 completion source."):
		return

	if not require(shop.stock_bands.size() == 3 and shop.stock_bands[0].item_level == 1 and shop.stock_bands[1].item_level == 10 and shop.stock_bands[2].item_level == 20, "Starting City shop must expose ilvl 1, 10, and 20 bands."):
		return
	var ilvl1_shop_definitions: Array = shop.stock_bands[0].item_definitions
	var ilvl10_shop_definitions: Array = shop.stock_bands[1].item_definitions
	var ilvl20_shop_definitions: Array = shop.stock_bands[2].item_definitions
	for definition in ilvl1_shop_definitions:
		if not require(definition.resource_path.contains("rustchain_initiate"), "The unchanged ilvl 1 shop band must use Rustchain Initiate."):
			return
	for definition in ilvl10_shop_definitions:
		if definition.equipment_slot in SLOTS:
			if not require(definition.resource_path.contains("ironwake_sentinel"), "The seven core ilvl 10 shop slots must use Ironwake Sentinel."):
				return
		else:
			if not require(definition.resource_path.contains("ironward_vanguard/ironward_"), "The ilvl 10 accessory shop definitions must remain unchanged."):
				return
	for definition in ilvl20_shop_definitions:
		if not require(definition.equipment_slot in SLOTS and definition.resource_path.contains("ironward_vanguard/boar_"), "The ilvl 20 shop band must use only the seven Ironward core slots."):
			return

	var mob_counts := {1: 0, 10: 0, 20: 0}
	for file_name in DirAccess.get_files_at("res://data/mobs"):
		if not file_name.ends_with(".tres"):
			continue
		var mob: Resource = load("res://data/mobs/%s" % file_name)
		var expected_source: Resource
		if ILVL1_MOB_IDS.has(mob.id):
			expected_source = ilvl1_source
		elif ILVL10_MOB_IDS.has(mob.id):
			expected_source = ilvl10_source
		else:
			if not require(ILVL20_MOB_IDS.has(mob.id), "Every current mob must belong to one approved equipment tier: %s" % mob.id):
				return
			expected_source = ilvl20_source
		if not require(mob.equipment_drop_table == expected_source, "Mob %s must use its approved source-driven item tier." % mob.id):
			return
		mob_counts[expected_source.item_level] += 1
	if not require(mob_counts == {1: 5, 10: 5, 20: 5}, "The 15 ordinary mobs must split evenly across ilvl 1/10/20 sources."):
		return

	var connected_definitions: Array = []
	connected_definitions.append_array(ilvl1_source.common_items)
	connected_definitions.append_array(ilvl1_source.uncommon_items)
	connected_definitions.append_array(ilvl1_source.rare_items)
	connected_definitions.append_array(ilvl10_source.common_items)
	connected_definitions.append_array(ilvl10_source.uncommon_items)
	connected_definitions.append_array(ilvl10_source.rare_items)
	connected_definitions.append_array(ilvl20_source.common_items)
	connected_definitions.append_array(ilvl20_source.uncommon_items)
	connected_definitions.append_array(ilvl20_source.rare_items)
	connected_definitions.append_array(ilvl1_shop_definitions)
	connected_definitions.append_array(ilvl10_shop_definitions)
	connected_definitions.append_array(ilvl20_shop_definitions)
	var item_generator = ItemGeneratorScript.new()
	for quality in 3:
		for ironward_definition in ironward_by_quality[quality]:
			if not require(connected_definitions.has(ironward_definition), "Every Ironward Vanguard core definition must be connected to ilvl 20 drops or shop stock."):
				return
			var generated = item_generator.generate(ironward_definition, 20, NoRollRng.new())
			if not require(generated != null and generated.item_level == 20 and generated.rarity == quality, "Every live Ironward Vanguard core definition must generate correctly at ilvl 20."):
				return
			if ironward_definition.equipment_slot in ["weapon", "shield"]:
				if not require(ironward_definition.icon_texture != null and ironward_definition.hero_overlay_texture == null, "The ilvl 20 sword/shield must keep their current icon placeholders and no overlays."):
					return

	var simulation = load("res://scripts/core/simulation.gd").new(2718)
	var live_shop_counts := {1: 0, 10: 0, 20: 0}
	var live_listings: Array = simulation.shop_system.get_listings()
	if not require(live_listings.size() == 24, "The live Starting City shop must generate 24 listings across three bands."):
		return
	for listing in live_listings:
		var listed_item = listing.get("item_instance")
		if not require(listed_item != null and live_shop_counts.has(listed_item.item_level), "Every live shop listing must contain an ilvl 1, 10, or 20 ItemInstance."):
			return
		live_shop_counts[listed_item.item_level] += 1
	if not require(live_shop_counts == {1: 8, 10: 8, 20: 8}, "Each live shop band must generate exactly eight listings."):
		return
	for definition in rustchain_by_quality[2]:
		var result: Dictionary = simulation.receive_item_reward(definition, 1, 1)
		if not require(bool(result.get("equipped", false)), "Each supplied Rustchain slot must equip through the normal generated-item path."):
			return
	var main_ui = load("res://scripts/ui/main_ui.gd").new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame
	for slot in SLOTS:
		var icon := main_ui.find_child(ICON_NODES[slot], true, false) as TextureRect
		if not require(icon != null and icon.visible and icon.texture == simulation.hero_state.equipment.get_item(slot).definition.icon_texture, "Inventory must render the equipped Rustchain icon for %s." % slot):
			main_ui.free()
			return
	for slot in OVERLAY_NODES:
		var overlay := main_ui.find_child(OVERLAY_NODES[slot], true, false) as TextureRect
		if not require(overlay != null and overlay.visible and overlay.texture == simulation.hero_state.equipment.get_item(slot).definition.hero_overlay_texture, "Paper doll must render the supplied Rustchain overlay for %s." % slot):
			main_ui.free()
			return
	main_ui.free()

	print("PASS: Rustchain, Ironwake, and Ironward use live 5/5/5 mob tiers and ilvl 1/10/20 shop bands while the first dungeon remains ilvl 10.")
	quit()
