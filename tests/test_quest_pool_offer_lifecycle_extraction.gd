extends SceneTree

const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const QUEST_PATHS := [
	"res://data/quests/0001_goblin_road_problem.tres",
	"res://data/quests/0002_wolf_hunt.tres",
]

func _init() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var quest_templates: Array = []
	for quest_path in QUEST_PATHS:
		var quest_template: Resource = load(quest_path)
		assert(quest_template != null, "QuestPool lifecycle test templates must load.")
		quest_templates.append(quest_template)

	var quest_pool = QuestPoolScript.new([], rng)
	quest_pool.set_quest_templates(quest_templates)
	if not quest_pool.has_method("handle_quest_event"):
		push_error("QuestPool must own quest-offer lifecycle events.")
		quit(1)
		return
	var initial_offers: Array = quest_pool.get_available_quests()
	assert(initial_offers.size() == 2, "Focused QuestPool lifecycle test requires two offers.")

	var turned_in_offer = initial_offers[0]
	var untouched_offer = initial_offers[1]
	var turn_in_event = QuestEventScript.new(QuestEventScript.HERO_TURNED_IN_QUEST, "Алексей", turned_in_offer)
	quest_pool.handle_quest_event(turn_in_event, "VISITING_MARKET")
	var after_turn_in: Array = quest_pool.get_available_quests()
	assert(after_turn_in[0] != turned_in_offer, "QuestPool must immediately replace a turned-in offer.")
	assert(after_turn_in[1] == untouched_offer, "QuestPool must preserve untouched offers after turn-in.")

	var cancelled_offer = after_turn_in[0]
	var death_event = QuestEventScript.new(QuestEventScript.HERO_DIED, "Алексей", cancelled_offer)
	quest_pool.handle_quest_event(death_event, "DEAD_RESPAWNING")
	assert(quest_pool.get_available_quests()[0] == cancelled_offer, "QuestPool must retain a cancelled offer during resurrection.")

	var recovery_event = QuestEventScript.new(QuestEventScript.HERO_RECOVERING_IN_CITY, "Алексей", cancelled_offer)
	quest_pool.handle_quest_event(recovery_event, "RECOVERING_IN_CITY")
	assert(quest_pool.get_available_quests()[0] == cancelled_offer, "QuestPool must wait until city recovery reaches quest choice.")
	quest_pool.handle_quest_event(recovery_event, "CHOOSING_QUEST")
	assert(quest_pool.get_available_quests()[0] != cancelled_offer, "QuestPool must replace the cancelled offer when recovery returns to quest choice.")
	assert(quest_pool.get_available_quests()[1] == untouched_offer, "Delayed cancellation refresh must still preserve untouched offers.")

	print("PASS: QuestPool owns immediate and delayed quest-offer replacement lifecycle.")
	quit()
