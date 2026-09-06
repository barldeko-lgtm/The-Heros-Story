extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const DiaryNarratorScript = preload("res://scripts/narrative/diary_narrator.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")
const QuestDiaryTextDefinitionScript = preload("res://scripts/model/definitions/quest_diary_text_definition.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const DefaultDiaryText = preload("res://data/narrative/quests/ordinary_quest_diary.tres")
const DefaultDeathDiaryText = preload("res://data/narrative/death_diary.tres")

func _init() -> void:
	assert(DefaultDiaryText.selected_variants.size() == 1, "The first ordinary-quest diary slice must start with one authored selection phrase.")
	assert(DefaultDiaryText.completed_variants.size() == 1, "The first ordinary-quest diary slice must start with one authored completion phrase.")
	assert(DefaultDeathDiaryText.variants.size() == 1, "The shared death diary slice must start with one authored phrase.")
	test_authored_quest_override()
	test_successful_quest_diary_flow()
	test_failed_quest_diary_flow()
	print("PASS: Ordinary quests write selection/success plus shared contextual death Diary entries from external phrase data.")
	quit()

func test_authored_quest_override() -> void:
	var mob = MobDefinitionScript.new()
	mob.id = "diary_test_mob"
	mob.display_name = "тестовый противник"
	var quest_template = QuestDefinitionScript.new()
	quest_template.id = "diary_test_quest"
	quest_template.display_name = "Особая работа"
	quest_template.mob_definition = mob
	var authored_text = QuestDiaryTextDefinitionScript.new()
	authored_text.selected_variants = PackedStringArray(["Особая запись: {hero} выбрал «{quest}»."])
	quest_template.diary_text = authored_text
	var offer = QuestOfferScript.new(quest_template, 1, 1.0, 10)
	var event = QuestEventScript.new(QuestEventScript.HERO_SELECTED_QUEST, "Алексей", offer)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var narrator = DiaryNarratorScript.new(rng)
	assert(narrator.describe_quest_event(event) == "Особая запись: Алексей выбрал «Особая работа».", "A quest-specific diary resource must override the shared ordinary-quest phrase bank.")

func test_successful_quest_diary_flow() -> void:
	var simulation = SimulationScript.new(12345)
	simulation.hero_state.hero_name = "Алексей"
	simulation.advance_time(10.0)
	assert(simulation.diary.entries.size() == 1, "Selecting an ordinary quest must immediately create one diary entry.")
	assert(simulation.diary.entries[0].begins_with("Тик 1 — "), "The first quest diary entry must display the real world tick when the quest was selected.")
	assert(simulation.diary.entries[0].contains("Алексей") and simulation.diary.entries[0].contains(simulation.quest_runner.quest_definition.display_name), "The selection entry must use real hero and quest names.")
	simulation.set_time_scale(100.0)
	var guard := 0
	while simulation.hero_state.gold == 0 and guard < 1500:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 1500, "The fixed safe quest must finish while testing diary completion.")
	assert(simulation.diary.entries.size() == 1, "A successful ordinary quest must replace its temporary selection entry with one completion entry.")
	assert(simulation.diary.entries[0].contains(str(simulation.hero_state.gold)), "The completion entry must use the real Gold reward.")
	assert(not simulation.diary.entries[0].contains("новым делом"), "The temporary quest-selection entry must not remain after successful turn-in.")

func test_failed_quest_diary_flow() -> void:
	var simulation = SimulationScript.new(54321)
	simulation.hero_state.hero_name = "Борис"
	simulation.advance_time(10.0)
	assert(simulation.diary.entries.size() == 1, "The failed-quest diary case must start from the normal selection entry.")
	var quest = simulation.quest_runner.quest_definition
	var mob_name: String = simulation.quest_runner.quest_definition.mob_definition.display_name
	var failure_event = QuestEventScript.new(
		QuestEventScript.HERO_DIED,
		"Борис",
		quest,
		0,
		0,
		null,
		0,
		quest.mob_count
	)
	simulation.record_quest_diary_event(failure_event, 77)
	assert(simulation.diary.entries.size() == 1, "Quest death must remove the temporary selection entry and leave only the contextual death entry.")
	assert(simulation.diary.entries[0].begins_with("Тик 77 — "), "A quest failure diary entry must display the supplied event world tick.")
	assert(simulation.diary.entries[0].contains("Борис") and simulation.diary.entries[0].contains(mob_name), "The failure entry must use the real hero and enemy names.")
	assert(simulation.diary.entries[0].contains(quest.display_name) and simulation.diary.entries[0].contains("задания"), "Quest death must identify the ordinary quest activity by its real name.")
