extends SceneTree

const WILD_BOAR_PATH := "res://data/mobs/0005_wild_boar.tres"
const QUEST_PATHS := [
	"res://data/quests/0002_wolf_hunt.tres",
	"res://data/quests/0003_bear_hunt.tres",
	"res://data/quests/0004_granary_rat_problem.tres",
	"res://data/quests/0005_boars_in_fields.tres",
	"res://data/quests/0006_trade_road_ambush.tres",
	"res://data/quests/0007_old_mill_webs.tres",
	"res://data/quests/0008_fearless_elk.tres",
]
const EXPECTED_SLOTS := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield"]

class ScriptedRng:
	extends RefCounted

	var float_values: Array = []
	var int_values: Array = []

	func _init(initial_float_values: Array, initial_int_values: Array = []) -> void:
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
	var loot_generator_script: Script = load("res://scripts/loot/loot_generator.gd")
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var wild_boar: Resource = load(WILD_BOAR_PATH)
	assert(loot_generator_script != null and simulation_script != null and wild_boar != null, "Boar drop scripts and data must load.")

	assert(wild_boar.equipment_drop_table != null, "Wild Boar must reference its source-driven equipment drop table.")
	assert(wild_boar.equipment_drop_table.item_level == 1, "Wild Boar must use the ilvl 1 Ironwake Sentinel source.")
	assert(is_equal_approx(wild_boar.equipment_drop_table.drop_chance, 0.05), "Wild Boar equipment drop chance must be 5%.")
	assert(wild_boar.equipment_drop_table.common_items.size() == 7, "Wild Boar must expose all seven current equipment slots.")
	assert(wild_boar.equipment_drop_table.uncommon_items.size() == 7, "Every current slot must have an Uncommon variant.")
	assert(wild_boar.equipment_drop_table.rare_items.size() == 7, "Every current slot must have a Rare variant.")

	var loot_generator = loot_generator_script.new()
	var no_drop = loot_generator.roll_mob_equipment(wild_boar, ScriptedRng.new([0.05]))
	assert(no_drop == null, "A 5% drop chance must reject rolls at or above 0.05.")

	var rarity_cases := [
		[0.0, 0],
		[0.699999, 0],
		[0.70, 1],
		[0.949999, 1],
		[0.95, 2],
		[0.999999, 2],
	]
	for slot_index in EXPECTED_SLOTS.size():
		for rarity_case in rarity_cases:
			var rolled_item = loot_generator.roll_mob_equipment(
				wild_boar,
				ScriptedRng.new([0.0, rarity_case[0]], [slot_index])
			)
			assert(rolled_item != null, "A successful Wild Boar equipment roll must return an item.")
			assert(rolled_item.equipment_slot == EXPECTED_SLOTS[slot_index], "The slot roll must select the matching current equipment slot.")
			assert(rolled_item.quality == rarity_case[1], "Rarity boundaries must implement 70% Common / 25% Uncommon / 5% Rare.")

	var simulation = simulation_script.new(1)
	var drop_result: Dictionary = simulation.resolve_mob_equipment_drop(
		wild_boar,
		1,
		ScriptedRng.new([0.0, 0.95, 0.5], [0, 0, 0])
	)
	assert(drop_result["item_definition"] != null, "A successful combat drop roll must return the awarded definition.")
	assert(drop_result["item_instance"] != null and drop_result["item_instance"].item_level == 1, "A successful Wild Boar drop must generate an ilvl 1 ItemInstance.")
	assert(drop_result["item_definition"].equipment_slot == "helmet", "The scripted slot roll must award the helmet.")
	assert(drop_result["item_definition"].quality == 2, "The scripted rarity roll must award the Rare variant.")
	assert(drop_result["item_definition"].resource_path.contains("ironwake_sentinel"), "Wild Boar equipment must come from the Ironwake Sentinel visual family.")
	assert(drop_result["equipped"], "The first dropped item for an empty slot must use the current automatic equip flow.")
	assert(simulation.hero_state.equipment.get_item("helmet") != null, "The dropped helmet must reach hero equipment.")

	for quest_path in QUEST_PATHS:
		var quest: Resource = load(quest_path)
		assert(quest != null, "Existing quest data must still load: %s" % quest_path)
		assert(not has_property(quest, "item_reward_pool"), "Ordinary quests must retain Gold rewards only.")

	print("PASS: Wild Boar uses 5% equipment drops, seven slots, 70/25/5 rarities, and Gold-only quests.")
	quit()

func has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if property["name"] == property_name:
			return true
	return false
