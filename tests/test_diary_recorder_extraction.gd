extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func _init() -> void:
	if not FileAccess.file_exists("res://scripts/narrative/diary_recorder.gd"):
		printerr("FAIL: DiaryRecorder has not been extracted")
		quit(1)
		return
	var simulation = SimulationScript.new(12345)
	var recorder = simulation.diary_recorder
	check(recorder.diary == simulation.diary, "Recorder must use the live Diary")
	check(recorder.diary_narrator == simulation.diary_narrator, "Narrator compatibility access must expose the same instance")
	simulation.advance_time(10.0)
	check(recorder.active_quest_diary_entry_id > 0, "Recorder owns the temporary quest entry")
	check(simulation.active_quest_diary_entry_id == recorder.active_quest_diary_entry_id, "Compatibility id must not diverge")
	var tick: int = simulation.world_clock.world_tick
	var gold: int = simulation.hero_state.gold
	var hp: float = simulation.hero_state.current_hp
	var state: String = simulation.hero_state.loop_state
	var rng_state = simulation.seeded_rng.get_rng().state
	var quest = simulation.quest_runner.quest_definition
	var event = QuestEventScript.new(QuestEventScript.HERO_TURNED_IN_QUEST, simulation.hero_state.hero_name, quest)
	simulation.record_quest_diary_event(event, 77)
	check(simulation.diary.entries.size() == 1 and simulation.diary.entries[0].begins_with("Тик 77 — "), "Completion replaces temporary selection at the supplied tick")
	check(recorder.active_quest_diary_entry_id == -1, "Completed quest clears recorder id")
	simulation.record_quest_diary_event(QuestEventScript.new(QuestEventScript.HERO_SELECTED_QUEST, simulation.hero_state.hero_name, quest), 78)
	simulation.clear_active_quest_diary_entry()
	check(simulation.diary.entries.size() == 1 and simulation.active_quest_diary_entry_id == -1, "External cancellation removes only the temporary entry")
	simulation.clear_active_quest_diary_entry()
	check(simulation.diary.entries.size() == 1, "Repeated cancellation is harmless")
	var narrator = simulation.diary_narrator
	simulation.diary_narrator = null
	simulation.record_death_diary_entry("Hero", "Enemy", "quest", "Quest", 79)
	check(simulation.diary.entries.size() == 1, "Null narrator compatibility preserves no-op behaviour")
	simulation.diary_narrator = narrator
	check(recorder.diary_narrator == narrator, "Narrator reassignment reaches recorder")
	check(simulation.world_clock.world_tick == tick and simulation.hero_state.gold == gold and simulation.hero_state.current_hp == hp and simulation.hero_state.loop_state == state, "Diary operations cannot change gameplay")
	check(simulation.seeded_rng.get_rng().state == rng_state, "Diary operations cannot consume gameplay RNG")
	if failures == 0:
		print("PASS: DiaryRecorder owns temporary entry lifecycle, preserves public access and leaves gameplay unchanged")
	quit(0 if failures == 0 else 1)
