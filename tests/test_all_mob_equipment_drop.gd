extends SceneTree

const MOB_DIRECTORY := "res://data/mobs"
const IRONWAKE_DROP_TABLE_PATH := "res://data/loot/ironwake_sentinel_ilvl1_drop_table.tres"
const IRONWARD_DROP_TABLE_PATH := "res://data/loot/ironward_vanguard_ilvl10_jewelry_drop_table.tres"
const IRONWAKE_MOB_IDS := ["goblin", "giant_rat", "wild_boar", "wolf", "bandit"]
const EXPECTED_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield"]

class ScriptedRng:
	extends RefCounted

	var float_values: Array = []
	var int_values: Array = []

	func _init(initial_float_values: Array, initial_int_values: Array = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		return float(float_values.pop_front())

	func randi_range(_from: int, _to: int) -> int:
		return int(int_values.pop_front())

func _init() -> void:
	var ironwake_drop_table: Resource = load(IRONWAKE_DROP_TABLE_PATH)
	var ironward_drop_table: Resource = load(IRONWARD_DROP_TABLE_PATH)
	if ironwake_drop_table == null or ironward_drop_table == null:
		fail("Both current initial-city equipment drop tables must exist.")
		return

	var loot_generator_script: Script = load("res://scripts/loot/loot_generator.gd")
	var loot_generator = loot_generator_script.new()
	var mob_files: PackedStringArray = DirAccess.get_files_at(MOB_DIRECTORY)
	var resource_files: Array[String] = []
	for file_name in mob_files:
		if file_name.ends_with(".tres"):
			resource_files.append(file_name)
	resource_files.sort()
	assert(resource_files.size() == 15, "The current initial-city set must contain 15 mob definitions.")

	var ironwake_count := 0
	var ironward_count := 0
	for file_name in resource_files:
		var mob: Resource = load("%s/%s" % [MOB_DIRECTORY, file_name])
		assert(mob != null, "Every mob resource must load: %s" % file_name)
		var expected_table: Resource = ironwake_drop_table if IRONWAKE_MOB_IDS.has(mob.id) else ironward_drop_table
		var expected_item_level: int = 1 if IRONWAKE_MOB_IDS.has(mob.id) else 10
		assert(mob.equipment_drop_table == expected_table, "Each mob must use the equipment source assigned to its strength group: %s" % file_name)
		if expected_table == ironwake_drop_table:
			ironwake_count += 1
		else:
			ironward_count += 1
		assert(is_equal_approx(mob.equipment_drop_table.drop_chance, 0.05), "Every current mob must keep the 5% drop chance.")
		assert(mob.equipment_drop_table.item_level == expected_item_level, "Each current mob must keep its assigned source-driven item level.")
		var expected_slot_count: int = 7 if expected_item_level == 1 else 11
		assert(mob.equipment_drop_table.common_items.size() == expected_slot_count, "Each mob source must expose its approved Common slot count.")
		assert(mob.equipment_drop_table.uncommon_items.size() == expected_slot_count, "Each mob source must expose its approved Uncommon slot count.")
		assert(mob.equipment_drop_table.rare_items.size() == expected_slot_count, "Each mob source must expose its approved Rare slot count.")

		var no_drop = loot_generator.roll_mob_equipment(mob, ScriptedRng.new([0.05]))
		assert(no_drop == null, "Every mob must reject equipment rolls at or above 5%.")
		var rare_shield = loot_generator.roll_mob_equipment(mob, ScriptedRng.new([0.0, 0.95], [6]))
		assert(rare_shield != null and rare_shield.equipment_slot == EXPECTED_SLOTS[6] and rare_shield.quality == 2, "Every mob must keep the shared slot and 70/25/5 rarity rolls.")

	assert(ironwake_count == 5 and ironward_count == 10, "Current mobs must split into five ilvl 1 Ironwake and ten ilvl 10 jewelry-enabled Ironward sources.")
	print("PASS: Current mobs use the approved five/ten split across ilvl 1 and jewelry-enabled ilvl 10 drop tables.")
	quit()

func fail(message: String) -> void:
	push_error(message)
	quit(1)
