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
			if not require(definition != null, "Every ilvl 20 accessory definition must load: %s" % path):
				return
			if not require(definition.equipment_slot == slot and definition.quality == quality, "Every ilvl 20 accessory must keep its mechanical slot and rarity."):
				return
			if not require(definition.icon_texture != null and definition.icon_texture.get_size() == Vector2(300, 300), "Every ilvl 20 accessory must use its supplied 300x300 icon."):
				return
			if not require(definition.hero_overlay_texture == null, "Jewelry and Belt must remain inventory/equipment-icon only."):
				return
			var generated = item_generator.generate(definition, 20, NoRollRng.new())
			if not require(generated != null and generated.item_level == 20 and generated.rarity == quality, "Every new accessory must generate as an ilvl 20 item in its authored rarity."):
				return
			if slot == "belt":
				if not require(belt_rules.get_max_potion_level(generated) == 20, "The new ilvl 20 Belt must support ilvl 20 healing potions."):
					return
				var expected_healing := float(quality + 1) * 150.0
				if not require(is_equal_approx(belt_rules.get_potential_healing(generated), expected_healing), "The new Belt must combine its rarity capacity with ilvl 20 potions."):
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
		if not require(old_pool.size() == 12, "The existing ilvl 10 twelve-slot source must remain unchanged."):
			return
		if not require(new_pool.size() == 12, "Every ilvl 20 rarity pool must expand from seven core slots to all twelve equipment slots."):
			return
		if not require(new_pool.slice(7, 12) == accessories_by_quality[quality], "The ilvl 20 source must append necklace, earrings, both rings, and Belt in stable slot order."):
			return

	var shop: Resource = load(SHOP_PATH)
	if not require(shop != null and shop.stock_bands.size() == 3, "Starting City must keep its three equipment bands."):
		return
	var ilvl20_band: Resource = shop.stock_bands[2]
	if not require(ilvl20_band.item_level == 20 and ilvl20_band.white_listings == 6 and ilvl20_band.uncommon_listings == 2, "The ilvl 20 shop band must keep six White and two Green listings."):
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
	if not require(dungeon != null and dungeon.completion_equipment_source == ilvl10_source and dungeon.completion_equipment_source.item_level == 10, "The first dungeon must remain on the unchanged ilvl 10 source."):
		return

	var simulation = load("res://scripts/core/simulation.gd").new(2020)
	var live_counts := {1: 0, 10: 0, 20: 0}
	for listing in simulation.shop_system.get_listings():
		var item = listing.get("item_instance")
		if not require(item != null and live_counts.has(item.item_level), "Every generated shop listing must contain a supported equipment level."):
			return
		live_counts[item.item_level] += 1
	if not require(live_counts == {1: 8, 10: 8, 20: 8}, "The expanded candidate pool must preserve exactly eight live listings per shop band."):
		return

	print("PASS: ilvl 20 jewelry and Belt use supplied icons, join drops/shop, and the Belt supports ilvl 20 potions while ilvl 10/dungeon stay unchanged.")
	quit()
