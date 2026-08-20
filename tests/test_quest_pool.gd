extends SceneTree

const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")

func _init() -> void:
	var quest_pool = QuestPoolScript.new()
	var quests: Array = quest_pool.get_available_quests()

	assert(not quests.is_empty(), "QuestPool must load quest resources from res://data/quests.")
	for quest_definition in quests:
		assert(quest_definition != null, "QuestPool must not return null quests.")
		assert(quest_definition.mob_definition != null, "Every loaded quest must reference a mob.")

	print("PASS: QuestPool loads current quest resources without hard-coded quest preloads.")
	quit()
