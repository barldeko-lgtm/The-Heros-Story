extends SceneTree

const JEWELRY_DIRECTORY := "res://data/items/visual_families/ironward_vanguard"
const JEWELRY_DROP_TABLE_PATH := "res://data/loot/ironward_vanguard_ilvl10_jewelry_drop_table.tres"
const LEGACY_SEVEN_SLOT_TABLE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
const SPIDER_PATH := "res://data/mobs/0007_giant_spider.tres"
const BANDIT_PATH := "res://data/mobs/0006_bandit.tres"
const EXPECTED_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield", "necklace", "earrings", "ring_1", "ring_2"]
const JEWELRY_FILES := {
	"necklace": "ironward_necklace",
	"earrings": "ironward_earrings",
	"ring_1": "ironward_ring_1",
	"ring_2": "ironward_ring_2",
}
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const WEAK_MOB_IDS := ["goblin", "giant_rat", "wild_boar", "wolf", "bandit"]
const JEWELRY_MOB_IDS := ["giant_spider", "bear", "rabid_elk", "bandit_veteran", "swamp_crocodile", "young_ogre", "cave_lizard", "forest_troll", "mountain_beast", "orc_raider"]

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
	for slot in JEWELRY_FILES:
		for quality in 3:
			var path: String = "%s/%s%s.tres" % [JEWELRY_DIRECTORY, JEWELRY_FILES[slot], RARITY_SUFFIXES[quality]]
			if not ResourceLoader.exists(path):
				fail_test("Missing ilvl 10 jewelry definition: %s" % path)
				return
			var definition: Resource = load(path)
			assert(definition.equipment_slot == slot and definition.quality == quality, "Every jewelry definition must keep its slot and rarity alignment.")
			assert(definition.icon_texture != null and definition.hero_overlay_texture == null, "Jewelry needs an inventory icon and no hero paper-doll overlay.")
			assert(definition.icon_texture.get_size() == Vector2(300.0, 300.0), "Supplied jewelry icons must remain unchanged at 300x300.")

	if not ResourceLoader.exists(JEWELRY_DROP_TABLE_PATH):
		fail_test("Missing 11-slot ilvl 10 jewelry drop table.")
		return
	var jewelry_table: Resource = load(JEWELRY_DROP_TABLE_PATH)
	var legacy_table: Resource = load(LEGACY_SEVEN_SLOT_TABLE_PATH)
	assert(jewelry_table.item_level == 10 and is_equal_approx(jewelry_table.drop_chance, 0.05), "Jewelry-enabled mob drops must remain ilvl 10 at 5%.")
	for pool in [jewelry_table.common_items, jewelry_table.uncommon_items, jewelry_table.rare_items]:
		assert(pool.size() == 11, "Jewelry-enabled drops must temporarily roll eleven slots without Belt.")
		for slot_index in EXPECTED_SLOTS.size():
			assert(pool[slot_index].equipment_slot == EXPECTED_SLOTS[slot_index], "All rarity pools must keep the same eleven-slot order.")
	assert(legacy_table.common_items.size() == 7, "The legacy seven-slot ilvl 10 source must remain available for compatibility.")

	var spider: Resource = load(SPIDER_PATH)
	var bandit: Resource = load(BANDIT_PATH)
	assert(spider.equipment_drop_table == jewelry_table, "Giant Spider, the sixth mob by Power, must start the ilvl 10 jewelry-enabled drop range.")
	assert(bandit.equipment_drop_table != jewelry_table and bandit.equipment_drop_table.item_level == 1, "The five weaker mobs must remain on seven-slot ilvl 1 drops.")
	var seen_weak: int = 0
	var seen_jewelry: int = 0
	for file_name in DirAccess.get_files_at("res://data/mobs"):
		if not file_name.ends_with(".tres"):
			continue
		var mob: Resource = load("res://data/mobs/%s" % file_name)
		if WEAK_MOB_IDS.has(mob.id):
			seen_weak += 1
			assert(mob.equipment_drop_table.item_level == 1 and mob.equipment_drop_table.common_items.size() == 7, "Every weaker mob must keep the ilvl 1 seven-slot source.")
		else:
			seen_jewelry += 1
			assert(JEWELRY_MOB_IDS.has(mob.id) and mob.equipment_drop_table == jewelry_table, "Every Giant-Spider-and-stronger mob must use the shared eleven-slot source.")
	assert(seen_weak == 5 and seen_jewelry == 10, "The current roster must split into five weaker and ten jewelry-enabled mobs.")
	assert(load("%s/ironward_ring_1.tres" % JEWELRY_DIRECTORY).icon_texture == load("%s/ironward_ring_2.tres" % JEWELRY_DIRECTORY).icon_texture, "Both ring slots must use the same supplied ring icon.")

	var generator = load("res://scripts/items/item_generator.gd").new()
	var common_ring: Resource = load("%s/ironward_ring_1.tres" % JEWELRY_DIRECTORY)
	var generated_ring = generator.generate(common_ring, 10, ScriptedRng.new([], [1]))
	assert(generated_ring != null and generated_ring.base_stats.size() == 1, "Common jewelry must generate exactly one inherent elemental Resistance.")
	assert(is_equal_approx(generated_ring.get_stat_bonus("cold_resistance"), 20.0), "The scripted ilvl 10 jewelry roll must grant 20 Cold Resistance.")
	assert(generated_ring.affixes.is_empty(), "Common jewelry must have no random affixes.")
	assert(generated_ring.get_item_power() > 0.0, "Inherent jewelry Resistance must contribute through shared ItemPower.")
	assert(generated_ring.get_tooltip_text().contains("Базовое сопротивление холоду: +20.00"), "Jewelry tooltip must name its inherent elemental Resistance.")

	var uncommon_necklace: Resource = load("%s/ironward_necklace_uncommon.tres" % JEWELRY_DIRECTORY)
	var generated_necklace = generator.generate(uncommon_necklace, 10, ScriptedRng.new([0.5], [0, 3]))
	assert(generated_necklace.affixes.size() == 1 and generated_necklace.affixes[0]["stat_id"] == "health", "Jewelry must use the approved Resistance/Health/Dodge/Accuracy/Critical pool.")
	assert(is_equal_approx(generated_necklace.get_stat_bonus("max_hp"), 78.0 / 4.0), "Jewelry Health affixes must use the shared ilvl 10 budget and stat cost.")

	var loot_generator = load("res://scripts/loot/loot_generator.gd").new()
	var rolled_ring_2 = loot_generator.roll_mob_equipment(spider, ScriptedRng.new([0.0, 0.0], [10]))
	assert(rolled_ring_2 != null and rolled_ring_2.equipment_slot == "ring_2", "The eleventh equal slot outcome must be Ring 2.")

	var simulation = load("res://scripts/core/simulation.gd").new(707)
	var reward: Dictionary = simulation.resolve_mob_equipment_drop(spider, 1, ScriptedRng.new([0.0, 0.0], [9, 2]))
	var equipped_ring = reward.get("item_instance")
	assert(equipped_ring != null and equipped_ring.item_level == 10 and equipped_ring.definition.equipment_slot == "ring_1", "A Spider jewelry roll must create and route a real ilvl 10 ring.")
	assert(reward.get("equipped", false), "The first ring must equip through ordinary virtual-equip routing.")
	assert(is_equal_approx(simulation.base_combat_stats.lightning_resistance, 20.0), "Equipped jewelry Resistance must reach resolved hero CombatStats.")

	var inventory_scene: PackedScene = load("res://scenes/ui/screens/inventory_screen.tscn")
	var inventory_screen = inventory_scene.instantiate()
	inventory_screen.setup(simulation)
	get_root().add_child(inventory_screen)
	await process_frame
	inventory_screen.refresh()
	var ring_icon := inventory_screen.find_child("Ring1EquipmentIcon", true, false) as TextureRect
	assert(ring_icon != null and ring_icon.visible and ring_icon.texture == equipped_ring.definition.icon_texture, "Equipped jewelry must appear in its reserved UI slot.")
	assert(inventory_screen.find_child("BeltEquipmentIcon", true, false).texture == null, "Belt must remain unimplemented in this slice.")

	inventory_screen.free()
	print("PASS: ilvl 10 jewelry adds four visible non-Belt slots to Giant Spider-and-stronger drops with approved stats and budgets.")
	quit()
