extends SceneTree

func _init() -> void:
	var quest = load("res://data/quests/0003_bear_hunt.tres")
	assert(quest != null, "Bear quest must exist.")
	assert(quest.id == "bear_hunt", "Bear quest ID must remain stable.")
	assert(quest.display_name == "Охота на медведей", "Bear quest display name must be Russian.")
	assert(quest.mob_definition != null, "Bear quest must reference a mob.")
	assert(quest.mob_definition.id == "bear", "Bear quest must use Bear.")
	assert(quest.mob_count_min == 4 and quest.mob_count_max == 6, "Bear offer count must roll from 4 through 6.")
	assert(quest.distance_km_min == 6 and quest.distance_km_max == 8, "Bear offer distance must roll from 6 through 8 km.")
	assert(quest.gold_per_mob_min == 20 and quest.gold_per_mob_max == 22, "Bear offer reward must roll from 20 through 22 gold per mob.")

	print("PASS: Bear quest template contains only approved integer ranges.")
	quit()
