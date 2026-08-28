extends SceneTree

const MOB_DIRECTORY := "res://data/mobs"
const SHARED_DROP_TABLE_PATH := "res://data/loot/initial_equipment_drop_table.tres"
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
	var drop_table: Resource = load(SHARED_DROP_TABLE_PATH)
	if drop_table == null:
		fail("The shared initial-city equipment drop table must exist.")
		return

	var loot_generator_script: Script = load("res://scripts/loot/loot_generator.gd")
	var loot_generator = loot_generator_script.new()
	var mob_files: PackedStringArray = DirAccess.get_files_at(MOB_DIRECTORY)
	var resource_files: Array[String] = []
	for file_name in mob_files:
		if file_name.ends_with(".tres"):
			resource_files.append(file_name)
	resource_files.sort()
	assert(resource_files.size() == 13, "The current initial-city set must contain 13 mob definitions.")

	for file_name in resource_files:
		var mob: Resource = load("%s/%s" % [MOB_DIRECTORY, file_name])
		assert(mob != null, "Every mob resource must load: %s" % file_name)
		assert(mob.equipment_drop_table == drop_table, "Every current mob must use the shared equipment drop table: %s" % file_name)
		assert(is_equal_approx(mob.equipment_drop_table.drop_chance, 0.05), "Every current mob must use the same 5% drop chance.")
		assert(mob.equipment_drop_table.item_level == 10, "Every current mob must currently drop the shared set at ilvl 10.")
		assert(mob.equipment_drop_table.common_items.size() == 7, "Every current mob must expose all seven Common slot results.")
		assert(mob.equipment_drop_table.uncommon_items.size() == 7, "Every current mob must expose all seven Uncommon slot results.")
		assert(mob.equipment_drop_table.rare_items.size() == 7, "Every current mob must expose all seven Rare slot results.")

		var no_drop = loot_generator.roll_mob_equipment(mob, ScriptedRng.new([0.05]))
		assert(no_drop == null, "Every mob must reject equipment rolls at or above 5%.")
		var rare_shield = loot_generator.roll_mob_equipment(mob, ScriptedRng.new([0.0, 0.95], [6]))
		assert(rare_shield != null and rare_shield.equipment_slot == EXPECTED_SLOTS[6] and rare_shield.quality == 2, "Every mob must use the shared slot and 70/25/5 rarity rolls.")

	print("PASS: All 13 current mobs share the 5% seven-slot 70/25/5 equipment drop table.")
	quit()

func fail(message: String) -> void:
	push_error(message)
	quit(1)
