extends SceneTree

const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")

func _init() -> void:
	var quest_pool = QuestPoolScript.new()
	var quests: Array = quest_pool.get_available_quests()

	assert(quest_pool.quest_templates.size() == 22, "Starting City must load all twenty-two authored quest templates.")
	assert(quests.size() == 12, "Starting City board must expose at most four offers from each of its three strength bands.")
	var band_counts := {"lower": 0, "middle": 0, "higher": 0}
	var seen_ids := {}
	for quest_offer in quests:
		assert(quest_offer != null, "QuestPool must not return null offers.")
		assert(quest_offer.mob_definition != null, "Every current quest offer must reference a mob.")
		assert(not seen_ids.has(quest_offer.id), "One board refresh must not contain duplicate quest templates.")
		seen_ids[quest_offer.id] = true
		var strength_band: String = str(quest_offer.template.strength_band)
		assert(band_counts.has(strength_band), "Every current quest offer must belong to an approved strength band.")
		band_counts[strength_band] += 1
	assert(band_counts == {"lower": 4, "middle": 4, "higher": 4}, "Starting City board must use the current 4/4/4 working composition when every band has enough eligible templates.")

	print("PASS: QuestPool rolls a unique current 4/4/4 board from the full Starting City template pool.")
	quit()
