extends SceneTree

const JEWELRY_DIRECTORY := "res://data/items/visual_families/ironward_vanguard"
const JEWELRY_DROP_TABLE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
const SPIDER_PATH := "res://data/mobs/0007_giant_spider.tres"
const BANDIT_PATH := "res://data/mobs/0006_bandit.tres"
const EXPECTED_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield", "necklace", "earrings", "ring_1", "ring_2", "belt"]
const JEWELRY_FILES := {
	"necklace": "ironward_necklace",
	"earrings": "ironward_earrings",
	"ring_1": "ironward_ring_1",
	"ring_2": "ironward_ring_2",
}
const RARITY_SUFFIXES := ["", "_uncommon", "_rare"]
const WEAK_MOB_IDS := ["goblin", "giant_rat", "wild_boar", "wolf", "bandit"]
const JEWELRY_MOB_IDS := ["giant_spider", "bear", "rabid_elk", "bandit_veteran", "swamp_crocodile"]
const ILVL20_MOB_IDS := ["young_ogre", "cave_lizard", "forest_troll", "mountain_beast", "orc_raider"]

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
		fail_test("Missing 12-slot ilvl 10 equipment drop table.")
		return
	var jewelry_table: Resource = load(JEWELRY_DROP_TABLE_PATH)
	assert(jewelry_table.item_level == 10 and is_equal_approx(jewelry_table.drop_chance, 0.05), "Jewelry-enabled mob drops must remain ilvl 10 at 5%.")
	for pool in [jewelry_table.common_items, jewelry_table.uncommon_items, jewelry_table.rare_items]:
		assert(pool.size() == 12, "The ilvl 10 source must roll all twelve equipment slots including Belt.")
		for slot_index in EXPECTED_SLOTS.size():
			assert(pool[slot_index].equipment_slot == EXPECTED_SLOTS[slot_index], "All rarity pools must keep the same twelve-slot order.")

	var spider: Resource = load(SPIDER_PATH)
	var bandit: Resource = load(BANDIT_PATH)
	assert(spider.equipment_drop_table == jewelry_table, "Giant Spider, the sixth mob by Power, must start the ilvl 10 jewelry-enabled drop range.")
	assert(bandit.equipment_drop_table != jewelry_table and bandit.equipment_drop_table.item_level == 1, "The five weaker mobs must remain on seven-slot ilvl 1 drops.")
	var seen_weak: int = 0
	var seen_jewelry: int = 0
	var seen_ilvl20: int = 0
	for file_name in DirAccess.get_files_at("res://data/mobs"):
		if not file_name.ends_with(".tres"):
			continue
		var mob: Resource = load("res://data/mobs/%s" % file_name)
		if WEAK_MOB_IDS.has(mob.id):
			seen_weak += 1
			assert(mob.equipment_drop_table.item_level == 1 and mob.equipment_drop_table.common_items.size() == 7, "Every weaker mob must keep the ilvl 1 seven-slot source.")
		elif JEWELRY_MOB_IDS.has(mob.id):
			seen_jewelry += 1
			assert(mob.equipment_drop_table == jewelry_table, "Every middle-tier mob must use the shared twelve-slot ilvl 10 source.")
		else:
			seen_ilvl20 += 1
			assert(ILVL20_MOB_IDS.has(mob.id) and mob.equipment_drop_table.item_level == 20 and mob.equipment_drop_table.common_items.size() == 12, "Every strongest mob must use the separate twelve-slot ilvl 20 source without reusing ilvl 10 jewelry.")
	assert(seen_weak == 5 and seen_jewelry == 5 and seen_ilvl20 == 5, "The current roster must split into five ilvl 1, five jewelry-enabled ilvl 10, and five jewelry-enabled ilvl 20 mobs.")
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

	var common_belt: Resource = load("%s/ironward_belt.tres" % JEWELRY_DIRECTORY)
	var uncommon_belt: Resource = load("%s/ironward_belt_uncommon.tres" % JEWELRY_DIRECTORY)
	var rare_belt: Resource = load("%s/ironward_belt_rare.tres" % JEWELRY_DIRECTORY)
	assert(common_belt != null and uncommon_belt != null and rare_belt != null, "The ilvl 10 Belt must have Common, Uncommon, and Rare definitions.")
	for belt_definition in [common_belt, uncommon_belt, rare_belt]:
		assert(belt_definition.equipment_slot == "belt" and belt_definition.icon_texture != null and belt_definition.hero_overlay_texture == null, "Belt definitions must use the existing Belt slot/icon without a paper-doll overlay.")
	var generated_belt = generator.generate(uncommon_belt, 10, ScriptedRng.new())
	assert(generated_belt != null and is_equal_approx(generated_belt.get_stat_bonus("max_hp"), 40.0), "The current ilvl 10 Belt must grant the Scope base Health of 40.")
	assert(generated_belt.affixes.is_empty() and is_zero_approx(generated_belt.rolled_total_modifier_budget), "Belt rarity must not use ordinary random affixes because rarity controls potion slots.")
	var belt_rules = load("res://scripts/items/belt_potion_rules.gd").new()
	assert(belt_rules.get_capacity(generated_belt) == 2 and is_equal_approx(belt_rules.get_potential_healing(generated_belt), 200.0), "Uncommon ilvl 10 Belt must provide two 100-HP potion slots.")

	var loot_generator = load("res://scripts/loot/loot_generator.gd").new()
	var rolled_ring_2 = loot_generator.roll_mob_equipment(spider, ScriptedRng.new([0.0, 0.0], [10]))
	assert(rolled_ring_2 != null and rolled_ring_2.equipment_slot == "ring_2", "The eleventh equal slot outcome must remain Ring 2.")
	var rolled_belt = loot_generator.roll_mob_equipment(spider, ScriptedRng.new([0.0, 0.0], [11]))
	assert(rolled_belt != null and rolled_belt.equipment_slot == "belt", "The twelfth equal slot outcome must produce Belt.")

	var simulation = load("res://scripts/core/simulation.gd").new(707)
	var reward: Dictionary = simulation.resolve_mob_equipment_drop(spider, 1, ScriptedRng.new([0.0, 0.0], [9, 2]))
	var equipped_ring = reward.get("item_instance")
	assert(equipped_ring != null and equipped_ring.item_level == 10 and equipped_ring.definition.equipment_slot == "ring_1", "A Spider jewelry roll must create and route a real ilvl 10 ring.")
	assert(reward.get("equipped", false), "The first ring must equip through ordinary virtual-equip routing.")
	assert(is_equal_approx(simulation.base_combat_stats.lightning_resistance, 20.0), "Equipped jewelry Resistance must reach resolved hero CombatStats.")
	var belt_reward: Dictionary = simulation.resolve_mob_equipment_drop(spider, 2, ScriptedRng.new([0.0, 0.0], [11]))
	var equipped_belt = belt_reward.get("item_instance")
	assert(equipped_belt != null and equipped_belt.definition.equipment_slot == "belt" and belt_reward.get("equipped", false), "A Belt drop must route through the existing virtual-equip pipeline.")
	assert(is_equal_approx(equipped_belt.get_stat_bonus("max_hp"), 40.0), "Equipped ilvl 10 Belt must contribute 40 Health through the normal stat pipeline.")

	var inventory_scene: PackedScene = load("res://scenes/ui/screens/inventory_screen.tscn")
	var inventory_screen = inventory_scene.instantiate()
	inventory_screen.setup(simulation)
	get_root().add_child(inventory_screen)
	await process_frame
	inventory_screen.refresh()
	var ring_icon := inventory_screen.find_child("Ring1EquipmentIcon", true, false) as TextureRect
	assert(ring_icon != null and ring_icon.visible and ring_icon.texture == equipped_ring.definition.icon_texture, "Equipped jewelry must appear in its reserved UI slot.")
	var belt_icon := inventory_screen.find_child("BeltEquipmentIcon", true, false) as TextureRect
	assert(belt_icon != null and belt_icon.visible and belt_icon.texture == equipped_belt.definition.icon_texture, "Equipped Belt must appear in its existing reserved UI slot.")

	inventory_screen.free()
	print("PASS: ilvl 10 jewelry and the potion-capacity Belt use all twelve equipment slots through shared drop, generation, equip, and UI paths.")
	quit()
