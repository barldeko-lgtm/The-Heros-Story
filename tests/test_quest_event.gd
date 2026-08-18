extends SceneTree

func _init() -> void:
	var hero_state_script: Script = load("res://scripts/hero/hero_state.gd")
	var quest_runner_script: Script = load("res://scripts/quests/quest_runner.gd")
	var quest_definition: Resource = load("res://data/quests/0001_goblin_road_problem.tres")
	assert(hero_state_script != null, "HeroState script must exist.")
	assert(quest_runner_script != null, "QuestRunner script must exist.")
	assert(quest_definition != null, "Quest definition must exist.")

	var hero_state: RefCounted = hero_state_script.new("Алексей")
	var quest_runner: RefCounted = quest_runner_script.new(quest_definition)
	var event = quest_runner.advance(hero_state)

	if typeof(event) != TYPE_OBJECT:
		push_error("QuestRunner must return a structured event, not narrative text.")
		quit(1)
		return
	assert(event.event_type == "HERO_SELECTED_QUEST", "Choosing a quest must emit HERO_SELECTED_QUEST.")
	assert(event.hero_name == "Алексей", "Quest event must preserve the hero name.")
	assert(event.quest_definition == quest_definition, "Quest event must preserve the selected quest.")
	assert(event.distance_remaining == 2, "Quest event must include the initial travel distance.")

	print("PASS: QuestRunner returns structured quest events without narrative text.")
	quit()
