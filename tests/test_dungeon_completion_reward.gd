extends SceneTree

const LootGeneratorScript = preload("res://scripts/loot/loot_generator.gd")
const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")
const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"
const SECOND_DUNGEON_PATH := "res://data/dungeons/starting_region/0002_blackfang_settlement.tres"

class ScriptedRng:
	var float_values: Array[float] = []
	var int_values: Array[int] = []

	func _init(initial_float_values: Array[float] = [], initial_int_values: Array[int] = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		assert(not float_values.is_empty(), "Scripted RNG ran out of float values.")
		return float_values.pop_front()

	func randi_range(from: int, to: int) -> int:
		assert(not int_values.is_empty(), "Scripted RNG ran out of integer values.")
		var value: int = int_values.pop_front()
		assert(value >= from and value <= to, "Scripted integer roll must stay inside the requested range.")
		return value

func _init() -> void:
	var dungeon = load(DUNGEON_PATH)
	var loot_generator = LootGeneratorScript.new()
	var item_generator = ItemGeneratorScript.new()

	var epic_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, ScriptedRng.new([0.249999], [0]))
	assert(not epic_roll.is_empty(), "Dungeon completion must always produce an equipment roll when its reward data is valid.")
	assert(int(epic_roll["rarity"]) == 3, "A rarity roll below 25% must produce Epic/Purple.")
	assert(int(epic_roll["item_level"]) == 5, "Dungeon completion equipment must use compressed ilvl 5.")
	assert(epic_roll["item_definition"].equipment_slot == "helmet", "The scripted first slot must resolve the helmet from the twelve-slot completion pool.")

	var rare_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, ScriptedRng.new([0.25], [11]))
	assert(int(rare_roll["rarity"]) == 2, "A rarity roll at or above 25% must produce Rare/Blue, giving the configured 75% Blue / 25% Purple split.")
	assert(rare_roll["item_definition"].equipment_slot == "belt", "The scripted last slot must resolve Belt from the twelve-slot completion pool.")
	var rare_belt = item_generator.generate(rare_roll["item_definition"], 5, ScriptedRng.new(), 2)
	assert(rare_belt != null and is_equal_approx(rare_belt.get_stat_bonus("max_hp"), 40.0), "Dungeon Belt rewards must preserve the former ilvl 10 base Health of 40 at ilvl 5.")
	assert(rare_belt.affixes.is_empty(), "Belt rarity must not gain ordinary random affixes; rarity is reserved for potion capacity.")
	var belt_rules = load("res://scripts/items/belt_potion_rules.gd").new()
	assert(belt_rules.get_capacity(rare_belt) == 3 and is_equal_approx(belt_rules.get_potential_healing(rare_belt), 300.0), "Rare dungeon Belt must provide three ilvl 5 potion slots worth 300 potential healing.")

	var epic_item = item_generator.generate(epic_roll["item_definition"], 5, ScriptedRng.new([0.5], [0, 0, 0]), 3)
	assert(epic_item != null, "ItemGenerator must support an Epic rarity override for a dungeon reward.")
	assert(epic_item.rarity == 3 and epic_item.affixes.size() == 3, "Epic dungeon equipment must be a real Purple ItemInstance with three affixes.")
	assert(epic_item.get_quality_display_name() == "Эпическое", "Epic dungeon equipment must expose its real rarity through ItemInstance presentation.")

	var second_dungeon = load(SECOND_DUNGEON_PATH)
	assert(second_dungeon != null, "The second dungeon completion definition must load.")
	var second_epic_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(second_dungeon, ScriptedRng.new([0.249999], [0]))
	assert(int(second_epic_roll["rarity"]) == 3 and int(second_epic_roll["item_level"]) == 10, "Blackfang Settlement must award Epic compressed ilvl 10 equipment below its 25% Epic threshold.")
	var second_rare_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(second_dungeon, ScriptedRng.new([0.25], [11]))
	assert(int(second_rare_roll["rarity"]) == 2 and int(second_rare_roll["item_level"]) == 10, "Blackfang Settlement must award Rare compressed ilvl 10 equipment at or above its Epic threshold.")
	assert(second_rare_roll["item_definition"].equipment_slot == "belt", "The compressed ilvl 10 completion pool must include Belt as its stable last slot.")
	var second_rare_belt = item_generator.generate(second_rare_roll["item_definition"], 10, ScriptedRng.new(), 2)
	assert(second_rare_belt != null and is_equal_approx(second_rare_belt.get_stat_bonus("max_hp"), 50.0), "A Rare ilvl 10 dungeon Belt must preserve the former ilvl 20 base Health of 50.")
	assert(belt_rules.get_capacity(second_rare_belt) == 3 and is_equal_approx(belt_rules.get_potential_healing(second_rare_belt), 450.0), "A Rare ilvl 10 dungeon Belt must provide three Level 10 potion slots worth 450 potential healing.")

	print("PASS: Both Starting Region dungeon reward pools preserve their strength while using compressed ilvl 5/10 tiers.")
	quit()
