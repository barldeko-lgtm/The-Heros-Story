extends SceneTree

const JEWELRY_SOURCE_PATH := "res://data/loot/ironward_vanguard_ilvl10_jewelry_drop_table.tres"
const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"
const SHOP_BAND_PATH := "res://data/shops/bands/starting_city_ironward_vanguard_ilvl10.tres"
const EXPECTED_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield", "necklace", "earrings", "ring_1", "ring_2"]

class ScriptedRng:
	extends RefCounted

	var float_values: Array = []
	var int_values: Array = []

	func _init(initial_float_values: Array = [], initial_int_values: Array = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		assert(not float_values.is_empty(), "Scripted RNG ran out of float values.")
		return float(float_values.pop_front())

	func randi_range(from: int, to: int) -> int:
		assert(not int_values.is_empty(), "Scripted RNG ran out of integer values.")
		var value: int = int(int_values.pop_front())
		assert(value >= from and value <= to, "Scripted integer roll must stay inside the requested range.")
		return value

func _init() -> void:
	call_deferred("run_test")

func fail_test(message: String) -> void:
	push_error(message)
	quit(1)

func run_test() -> void:
	var jewelry_source: Resource = load(JEWELRY_SOURCE_PATH)
	var dungeon: Resource = load(DUNGEON_PATH)
	var shop_band: Resource = load(SHOP_BAND_PATH)
	if jewelry_source == null or dungeon == null or shop_band == null:
		fail_test("Jewelry source, first dungeon, and ilvl 10 shop band must load.")
		return

	assert(dungeon.completion_equipment_source == jewelry_source, "The first dungeon must use the eleven-slot ilvl 10 jewelry source.")
	assert(dungeon.completion_equipment_source.rare_items.size() == 11, "Rare/Epic dungeon completion rewards must cover all eleven non-Belt slots.")

	var loot_generator = load("res://scripts/loot/loot_generator.gd").new()
	var rare_ring_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, ScriptedRng.new([0.25], [10]))
	assert(int(rare_ring_roll["rarity"]) == 2 and rare_ring_roll["item_definition"].equipment_slot == "ring_2", "The dungeon's eleventh equal outcome must produce a Rare Ring 2.")
	var epic_necklace_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, ScriptedRng.new([0.249999], [7]))
	assert(int(epic_necklace_roll["rarity"]) == 3 and epic_necklace_roll["item_definition"].equipment_slot == "necklace", "Dungeon jewelry must preserve the configured 25% Epic override.")
	var epic_necklace = load("res://scripts/items/item_generator.gd").new().generate(epic_necklace_roll["item_definition"], 10, ScriptedRng.new([0.5], [0, 0, 0, 0]), 3)
	assert(epic_necklace != null and epic_necklace.affixes.size() == 3 and is_equal_approx(epic_necklace.get_stat_bonus("fire_resistance"), 20.0 + epic_necklace.affixes[0]["value"]), "Epic dungeon jewelry must combine its inherent Resistance with three generated affixes.")

	assert(shop_band.item_level == 10 and shop_band.white_listings == 6 and shop_band.uncommon_listings == 2, "Adding jewelry must not change the ilvl 10 shop's 6 White / 2 Green listing counts.")
	var definitions_by_rarity := {0: [], 1: []}
	for definition in shop_band.item_definitions:
		assert(definition != null and int(definition.quality) in [0, 1], "Normal shop pool must remain White/Green only.")
		definitions_by_rarity[int(definition.quality)].append(definition)
	for rarity in [0, 1]:
		assert(definitions_by_rarity[rarity].size() == 11, "Each ilvl 10 shop rarity pool must expose eleven non-Belt slots.")
		var slots: Array[String] = []
		for definition in definitions_by_rarity[rarity]:
			slots.append(definition.equipment_slot)
		assert(slots == EXPECTED_SLOTS, "White and Green shop pools must keep the same eleven-slot order.")

	var shop_system_script: Script = load("res://scripts/economy/shop_system.gd")
	var shop_definition: Resource = load("res://data/shops/starting_city_shop.tres")
	var shop_system = shop_system_script.new(shop_definition, load("res://scripts/items/item_generator.gd").new(), 1)
	assert(shop_system.get_definitions_for_rarity(shop_band, 0).size() == 11, "ShopSystem must receive all eleven White candidates from the expanded band.")
	assert(shop_system.get_definitions_for_rarity(shop_band, 1).size() == 11, "ShopSystem must receive all eleven Green candidates from the expanded band.")
	var jewelry_listing_seen: bool = false
	for seed in range(1, 101):
		var seeded_shop = shop_system_script.new(shop_definition, load("res://scripts/items/item_generator.gd").new(), seed)
		assert(seeded_shop.get_listings().size() == 16, "Expanded candidate pools must keep the existing 16 total shop listings.")
		for listing in seeded_shop.get_listings():
			var item = listing.get("item_instance")
			if item != null and item.item_level == 10 and item.definition.equipment_slot in ["necklace", "earrings", "ring_1", "ring_2"]:
				jewelry_listing_seen = true
				break
		if jewelry_listing_seen:
			break
	assert(jewelry_listing_seen, "Real deterministic shop generation must be able to place ilvl 10 jewelry into stock.")

	print("PASS: First-dungeon Rare/Epic rewards and the ilvl 10 city shop both use all eleven non-Belt equipment slots.")
	quit()
