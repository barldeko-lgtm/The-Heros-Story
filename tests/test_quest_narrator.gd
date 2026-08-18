extends SceneTree

func _init() -> void:
	var narrator_script: Script = load("res://scripts/narrative/quest_narrator.gd")
	if narrator_script == null:
		push_error("QuestNarrator must turn quest events into Russian log text.")
		quit(1)
		return

	var hero_state_script: Script = load("res://scripts/hero/hero_state.gd")
	var quest_runner_script: Script = load("res://scripts/quests/quest_runner.gd")
	var quest_definition: Resource = load("res://data/quests/0001_goblin_road_problem.tres")
	var hero_state: RefCounted = hero_state_script.new("Алексей")
	var quest_runner: RefCounted = quest_runner_script.new(quest_definition)
	var narrator: RefCounted = narrator_script.new()

	var expected_event_types := [
		"HERO_SELECTED_QUEST",
		"HERO_TRAVELLING_TO_QUEST",
		"HERO_ARRIVED_AT_QUEST",
		"HERO_COMPLETED_QUEST",
		"HERO_RETURNING_TO_CITY",
		"HERO_RETURNED_TO_CITY",
		"HERO_TURNED_IN_QUEST",
	]
	var expected_messages := [
		"Алексей выбрал квест «Проблема у восточной дороги».",
		"Алексей идёт к цели. Осталось: 1 км.",
		"Алексей прибыл к цели.",
		"Алексей выполнил задание «Проблема у восточной дороги». Бой будет добавлен позже.",
		"Алексей возвращается в город. Осталось: 1 км.",
		"Алексей вернулся в город.",
		"Алексей сдал квест «Проблема у восточной дороги» и получил 20 золота.",
	]

	for index in expected_event_types.size():
		var event = quest_runner.advance(hero_state)
		assert(event.event_type == expected_event_types[index], "QuestRunner must emit the expected domain event for each quest step.")
		assert(narrator.describe(event) == expected_messages[index], "QuestNarrator must preserve the approved quest-log text.")

	print("PASS: Quest events are narrated outside QuestRunner.")
	quit()
