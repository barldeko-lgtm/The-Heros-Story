extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const ResurrectionDiaryText = preload("res://data/narrative/resurrection_diary.tres")

func _init() -> void:
	assert(ResurrectionDiaryText.natural_variants.size() == 1, "Natural resurrection Diary must start with one authored phrase.")
	assert(ResurrectionDiaryText.divine_variants.size() == 1, "Divine resurrection Diary must start with one authored phrase.")
	test_natural_resurrection_diary()
	test_divine_resurrection_diary()
	print("PASS: Natural and divine resurrection create distinct Diary entries with the real world tick.")
	quit()

func test_natural_resurrection_diary() -> void:
	var simulation = SimulationScript.new(9201)
	simulation.hero_state.hero_name = "Алексей"
	simulation.hero_state.loop_state = HeroState.DEAD_RESPAWNING
	simulation.hero_state.current_hp = 0.0
	simulation.quest_runner.respawn_ticks_remaining = 1
	var diary_count_before: int = simulation.diary.entries.size()

	simulation.on_world_tick_completed(42)

	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Natural resurrection must enter city recovery.")
	assert(simulation.diary.entries.size() == diary_count_before + 1, "Natural resurrection must add exactly one Diary entry.")
	var entry: String = simulation.diary.entries.back()
	assert(entry.begins_with("Тик 42 — "), "Natural resurrection Diary entry must use the completed world tick.")
	assert(entry.contains("Алексей") and entry.contains("обычного ожидания"), "Natural resurrection wording must identify the hero and natural path.")

func test_divine_resurrection_diary() -> void:
	var simulation = SimulationScript.new(9202)
	simulation.hero_state.hero_name = "Борис"
	simulation.hero_state.loop_state = HeroState.DEAD_RESPAWNING
	simulation.hero_state.current_hp = 0.0
	simulation.quest_runner.respawn_ticks_remaining = 20
	var diary_count_before: int = simulation.diary.entries.size()

	assert(simulation.use_instant_resurrection(), "Divine resurrection must succeed with enough energy.")

	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Divine resurrection must enter city recovery.")
	assert(simulation.diary.entries.size() == diary_count_before + 1, "Divine resurrection must add exactly one Diary entry.")
	var entry: String = simulation.diary.entries.back()
	assert(entry.begins_with("Тик 0 — "), "Immediate divine resurrection must use the current world tick.")
	assert(entry.contains("Борис") and entry.contains("Божественное вмешательство"), "Divine resurrection wording must clearly identify player intervention.")
