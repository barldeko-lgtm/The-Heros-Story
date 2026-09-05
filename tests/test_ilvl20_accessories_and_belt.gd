extends SceneTree

const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")
const BeltPotionRulesScript = preload("res://scripts/items/belt_potion_rules.gd")

const FAMILY_DIR := "res://data/items/visual_families/ironward_vanguard"
const ILVL10_SOURCE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
const ILVL20_SOURCE_PATH := "res://data/loot/ironward_vanguard_ilvl20_drop_table.tres"
const SHOP_PATH := "res://data/shops/starting_city_shop.tres"
const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"
const CORE_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield"]
const ACCESSORY_SLOTS := ["necklace", "earrings", "ring_1", "ring_2", "belt"]
const ACCESSORY_STEMS := {
	"necklace": "ironward_vanguard_necklace",
	"earrings": "ironward_vanguard_earrings",
	"ring_1": "ironward_vanguard_ring_1",
	"ring_2": "ironward_vanguard_ring_2",
	"belt": "ironward_vanguard_belt",
}
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]

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
	var item_generator = ItemGeneratorScript.new()
	var belt_rules = BeltPotionRulesScript.new()
	var accessories_by_quality: Array = [[], [], []]

	for quality in 3:
		for slot in ACCESSORY_SLOTS:
			var path := "%s/%s%s.tres" % [FAMILY_DIR, ACCESSORY_STEMS[slot], RARITY_SUFFIXES[quality]]
			var definition: Resource = load(path)
				if not require(definition != null, "Every compressed ilvl 10 accessory definition must load: %s" % path):
				return
				if not require(definition.equipment_slot == slot and definition.quality == quality, "Every compressed ilvl 10 accessory must keep its mechanical slot and rarity."):
				return
				if not require(definition.icon_texture != null and definition.icon_texture.get_size() == Vector2(300, 300), "Every compressed ilvl 10 accessory must use its supplied 300x300 icon."):
				return
			if not require(definition.hero_overlay_texture == null, "Jewelry and Belt must remain inventory/equipment-icon only."):
				return
				var generated = item_generator.generate(definition, 10, NoRollRng.new())
				if not require(generated != null and generated.item_level == 10 and generated.rarity == quality, "Every new accessory must generate as compressed ilvl 10 in its authored rarity."):
				return
			if slot == "belt":
					if not require(belt_rules.get_max_potion_level(generated) == 10, "The compressed ilvl 10 Belt must support compressed Level 10 healing potions."):
					return
				var expected_healing := float(quality + 1) * 150.0
					if not require(is_equal_approx(belt_rules.get_potential_healing(generated), expected_healing), "The new Belt must combine its rarity capacity with compressed Level 10 potions."):
					return
			accessories_by_quality[quality].append(definition)

	if not require(accessories_by_quality[0][2].icon_texture == accessories_by_quality[0][3].icon_texture, "Both mechanical ring slots must reuse the one supplied ring icon."):
		return

	var ilvl10_source: Resource = load(ILVL10_SOURCE_PATH)
	var ilvl20_source: Resource = load(ILVL20_SOURCE_PATH)
	if not require(ilvl10_source != null and ilvl20_source != null, "Both live accessory tiers must load."):
		return
	for quality in 3:
		var old_pool: Array = [ilvl10_source.common_items, ilvl10_source.uncommon_items, ilvl10_source.rare_items][quality]
		var new_pool: Array = [ilvl20_source.common_items, ilvl20_source.uncommon_items, ilvl20_source.rare_items][quality]
		if not require(old_pool.size() == 12, "The compressed ilvl 5 twelve-slot source must remain unchanged apart from its label."):
			return
		if not require(new_pool.size() == 12, "Every compressed ilvl 10 rarity pool must cover all twelve equipment slots."):
			return
		if not require(new_pool.slice(7, 12) == accessories_by_quality[quality], "The compressed ilvl 10 source must append necklace, earrings, both rings, and Belt in stable slot order."):
			return

	var shop: Resource = load(SHOP_PATH)
	if not require(shop != null and shop.stock_bands.size() == 3, "Starting City must keep its three equipment bands."):
		return
	var ilvl20_band: Resource = shop.stock_bands[2]
		if not require(ilvl20_band.item_level == 10 and ilvl20_band.white_listings == 6 and ilvl20_band.uncommon_listings == 2, "The compressed ilvl 10 shop band must keep six White and two Green listings."):
		return
	if not require(ilvl20_band.item_definitions.size() == 24, "The ilvl 20 shop candidate pool must contain all twelve slots in White and Green."):
		return
	for slot in ACCESSORY_SLOTS:
		var slot_count := 0
		for definition in ilvl20_band.item_definitions:
			if definition.equipment_slot == slot:
				slot_count += 1
		if not require(slot_count == 2, "The ilvl 20 shop pool must contain White and Green candidates for %s." % slot):
			return

	var dungeon: Resource = load(DUNGEON_PATH)
		if not require(dungeon != null and dungeon.completion_equipment_source == ilvl10_source and dungeon.completion_equipment_source.item_level == 5, "The first dungeon must use the same source at compressed ilvl 5."):
		return

	var simulation = load("res://scripts/core/simulation.gd").new(2020)
	var live_counts := {1: 0, 5: 0, 10: 0}
	for listing in simulation.shop_system.get_listings():
		var item = listing.get("item_instance")
		if not require(item != null and live_counts.has(item.item_level), "Every generated shop listing must contain a supported equipment level."):
			return
		live_counts[item.item_level] += 1
	if not require(live_counts == {1: 8, 5: 8, 10: 8}, "The compressed candidate pool must preserve exactly eight live listings per shop band."):
		return

	print("PASS: Former ilvl 20 jewelry/Belt preserve stats at compressed ilvl 10, with compatible compressed potion tiers.")
	quit()
