extends SceneTree

const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")

func _init() -> void:
	var quest_pool = QuestPoolScript.new()
	var quests: Array = quest_pool.get_available_quests()

	assert(quest_pool.quest_templates.size() == 22, "Starting City must load all twenty-two authored quest templates.")
	assert(quests.size() == 22, "Temporary development mode must expose every currently eligible Starting City quest template.")
	var band_counts := {"lower": 0, "middle": 0, "higher": 0}
	for quest_offer in quests:
		assert(quest_offer != null, "QuestPool must not return null offers.")
		assert(quest_offer.mob_definition != null, "Every current quest offer must reference a mob.")
		var strength_band: String = str(quest_offer.template.strength_band)
		assert(band_counts.has(strength_band), "Every current quest offer must belong to an approved strength band.")
		band_counts[strength_band] += 1
	assert(band_counts == {"lower": 8, "middle": 7, "higher": 7}, "Temporary development mode must not cap current offers at three per strength band.")

	print("PASS: QuestPool temporarily exposes all 22 eligible Starting City templates without the 3-per-band cap.")
	quit()
