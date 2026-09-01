extends SceneTree

const LootGeneratorScript = preload("res://scripts/loot/loot_generator.gd")
const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")
const DUNGEON_PATH := "res://data/dungeons/starting_region/0001_abandoned_iron_mines.tres"

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
	assert(int(epic_roll["item_level"]) == 10, "Dungeon completion equipment must use ilvl 10.")
	assert(epic_roll["item_definition"].equipment_slot == "helmet", "The scripted first slot must resolve the helmet from the eleven-slot completion pool.")

	var rare_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, ScriptedRng.new([0.25], [10]))
	assert(int(rare_roll["rarity"]) == 2, "A rarity roll at or above 25% must produce Rare/Blue, giving the configured 75% Blue / 25% Purple split.")
	assert(rare_roll["item_definition"].equipment_slot == "ring_2", "The scripted last slot must resolve Ring 2 from the eleven-slot completion pool.")

	var epic_item = item_generator.generate(epic_roll["item_definition"], 10, ScriptedRng.new([0.5], [0, 0, 0]), 3)
	assert(epic_item != null, "ItemGenerator must support an Epic rarity override for a dungeon reward.")
	assert(epic_item.rarity == 3 and epic_item.affixes.size() == 3, "Epic dungeon equipment must be a real Purple ItemInstance with three affixes.")
	assert(epic_item.get_quality_display_name() == "Эпическое", "Epic dungeon equipment must expose its real rarity through ItemInstance presentation.")

	print("PASS: Dungeon completion loot rolls eleven ilvl-10 slots at exactly 75% Rare / 25% Epic and generates real three-affix Epic ItemInstances.")
	quit()
