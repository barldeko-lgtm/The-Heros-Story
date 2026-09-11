extends SceneTree

const MID_MOB_DIRECTORY := "res://data/mobs/mid_region"
const TRANSITION_SOURCE_PATH := "res://data/loot/ironward_vanguard_ilvl20_drop_table.tres"
const AZURE_SOURCE_PATH := "res://data/loot/azure_dawnplate_ilvl15_drop_table.tres"
const CRIMSON_SOURCE_PATH := "res://data/loot/crimson_thornplate_ilvl20_drop_table.tres"
const GILDED_SOURCE_PATH := "res://data/loot/gilded_wyrm_ilvl25_drop_table.tres"

const AZURE_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "necklace", "earrings", "ring_1", "ring_2", "belt"]
const ARMOR_SLOTS := ["helmet", "chest", "gloves", "pants", "boots"]

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
	var transition_source: Resource = load(TRANSITION_SOURCE_PATH)
	var azure_source: Resource = load(AZURE_SOURCE_PATH)
	var crimson_source: Resource = load(CRIMSON_SOURCE_PATH)
	var gilded_source: Resource = load(GILDED_SOURCE_PATH)

	assert(transition_source != null and transition_source.item_level == 10, "The five Arden transition mobs must keep the existing ilvl 10 source.")
	assert_drop_source(azure_source, 15, AZURE_SLOTS)
	assert_drop_source(crimson_source, 20, ARMOR_SLOTS)
	assert_drop_source(gilded_source, 25, ARMOR_SLOTS)

	var mob_files: Array[String] = []
	for file_name in DirAccess.get_files_at(MID_MOB_DIRECTORY):
		if file_name.ends_with(".tres"):
			mob_files.append(file_name)
	mob_files.sort()
	assert(mob_files.size() == 26, "Arden must keep exactly 26 ordinary mob definitions.")

	var source_counts := {10: 0, 15: 0, 20: 0, 25: 0}
	for index in mob_files.size():
		var mob: Resource = load("%s/%s" % [MID_MOB_DIRECTORY, mob_files[index]])
		assert(mob != null and mob.equipment_drop_table != null, "Every Arden ordinary mob must have an equipment drop source: %s" % mob_files[index])
		var expected_source: Resource
		if index < 5:
			expected_source = transition_source
		elif index < 9:
			expected_source = azure_source
		elif index < 17:
			expected_source = crimson_source
		else:
			expected_source = gilded_source
		assert(mob.equipment_drop_table == expected_source, "Arden mob must use the drop source assigned to its progression band: %s" % mob_files[index])
		source_counts[int(expected_source.item_level)] += 1

	assert(source_counts == {10: 5, 15: 4, 20: 8, 25: 9}, "Arden mob drops must preserve 5 transition / 4 ilvl15 / 8 ilvl20 / 9 ilvl25 sources.")

	var loot_generator = load("res://scripts/loot/loot_generator.gd").new()
	for source_and_mob in [
		[azure_source, load("res://data/mobs/mid_region/0106_warg_pack_leader.tres")],
		[crimson_source, load("res://data/mobs/mid_region/0110_fire_salamander.tres")],
		[gilded_source, load("res://data/mobs/mid_region/0118_orc_shaman.tres")],
	]:
		var source: Resource = source_and_mob[0]
		var mob: Resource = source_and_mob[1]
		var rare_definition = loot_generator.roll_mob_equipment(mob, ScriptedRng.new([0.0, 0.95], [0]))
		assert(rare_definition != null and rare_definition.quality == 2, "Arden mob drops must preserve the normal 5 percent Rare outcome at ilvl %d." % source.item_level)

	print("PASS: Arden ordinary mobs use transition ilvl10 then Azure ilvl15, Crimson ilvl20, and Gilded ilvl25 equipment drops with the normal 5% / 70-25-5 rules.")
	quit()

func assert_drop_source(source: Resource, item_level: int, expected_slots: Array) -> void:
	assert(source != null, "Arden equipment drop source must load for ilvl %d." % item_level)
	assert(source.item_level == item_level and is_equal_approx(source.drop_chance, 0.05), "Arden ilvl %d source must use the normal 5 percent mob drop chance." % item_level)
	var pools := [source.common_items, source.uncommon_items, source.rare_items]
	for rarity in pools.size():
		var pool: Array = pools[rarity]
		assert(pool.size() == expected_slots.size(), "Arden ilvl %d rarity pool must cover every currently supplied slot." % item_level)
		for slot_index in expected_slots.size():
			var definition: Resource = pool[slot_index]
			assert(definition != null and definition.equipment_slot == expected_slots[slot_index], "Arden ilvl %d drop slots must remain aligned across rarities." % item_level)
			assert(int(definition.quality) == rarity, "Arden ilvl %d drop definitions must match Common/Uncommon/Rare pool quality." % item_level)
