extends SceneTree

func _init() -> void:
	var quest = load("res://data/quests/0003_bear_hunt.tres")
	assert(quest != null, "Bear quest must exist.")
	assert(quest.id == "bear_hunt", "Bear quest ID must remain stable.")
	assert(quest.display_name == "Охота на медведей", "Bear quest display name must be Russian.")
	assert(quest.mob_definition != null, "Bear quest must reference a mob.")
	assert(quest.mob_definition.id == "bear", "Bear quest must use Bear.")
	assert(quest.mob_count == 4, "Bear quest must contain 4 bears.")
	assert(is_equal_approx(quest.distance_km, 3.0), "Bear quest distance must be 3 km.")
	assert(quest.gold_reward == 40, "Bear quest reward must be 40 gold.")

	print("PASS: Bear quest contains 4 bears at distance 3 with 40 gold reward.")
	quit()
