extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const DefaultEquipmentAcquisitionDiaryText = preload("res://data/narrative/equipment_acquisition_diary.tres")
const TestItemDefinition = preload("res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres")

func _init() -> void:
	assert(DefaultEquipmentAcquisitionDiaryText.rare_variants.size() == 1, "Rare equipment Diary slice must start with one authored phrase.")
	assert(DefaultEquipmentAcquisitionDiaryText.epic_variants.size() == 1, "Epic equipment Diary slice must start with one authored phrase.")
	var simulation = SimulationScript.new(9201, null)
	simulation.hero_state.hero_name = "Алексей"

	var uncommon_result: Dictionary = simulation.receive_item_reward(TestItemDefinition, 41, 5, create_rng(1), 1)
	assert(uncommon_result.get("item_instance") != null, "Focused Diary test requires a generated Uncommon item.")
	assert(simulation.diary.entries.is_empty(), "Uncommon equipment must not create a Diary entry.")

	var rare_result: Dictionary = simulation.receive_item_reward(TestItemDefinition, 42, 5, create_rng(2), 2)
	var rare_item = rare_result.get("item_instance")
	assert(rare_item != null, "Focused Diary test requires a generated Rare item.")
	assert(simulation.diary.entries.size() == 1, "Rare equipment acquisition must create exactly one Diary entry.")
	assert(simulation.diary.entries[0].begins_with("Тик 42 — "), "Rare equipment Diary entry must use the real acquisition tick.")
	assert(simulation.diary.entries[0].contains("Алексей") and simulation.diary.entries[0].contains(rare_item.definition.display_name) and simulation.diary.entries[0].contains("редкий"), "Rare equipment Diary entry must identify the hero, item, and Rare quality.")

	var epic_result: Dictionary = simulation.receive_item_reward(TestItemDefinition, 43, 5, create_rng(3), 3)
	var epic_item = epic_result.get("item_instance")
	assert(epic_item != null, "Focused Diary test requires a generated Epic item.")
	assert(simulation.diary.entries.size() == 2, "Epic equipment acquisition must add exactly one more Diary entry.")
	assert(simulation.diary.entries[1].begins_with("Тик 43 — "), "Epic equipment Diary entry must use the real acquisition tick.")
	assert(simulation.diary.entries[1].contains("Алексей") and simulation.diary.entries[1].contains(epic_item.definition.display_name) and simulation.diary.entries[1].contains("эпический"), "Epic equipment Diary entry must identify the hero, item, and Epic quality.")

	print("PASS: Rare and Epic reward equipment create Diary entries while Uncommon equipment stays silent.")
	quit()

func create_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng
