extends SceneTree

func _init() -> void:
	var quest = load("res://data/quests/0001_goblin_road_problem.tres")
	assert(quest != null, "Goblin quest definition must exist.")
	assert(quest.id == "goblin_road_problem", "Quest ID must remain stable and semantic.")
	assert(quest.display_name == "Проблема у восточной дороги", "Quest display name must be Russian.")
	assert(quest.mob_definition.id == "goblin", "Quest must reference the Goblin definition.")
	assert(quest.mob_count_min == 4 and quest.mob_count_max == 6, "Goblin offer count must roll from 4 through 6.")
	assert(quest.distance_km_min == 1 and quest.distance_km_max == 3, "Goblin offer distance must roll from 1 through 3 km.")
	assert(quest.gold_per_mob_min == 7 and quest.gold_per_mob_max == 9, "Goblin offer reward must roll from 7 through 9 gold per mob.")

	print("PASS: Goblin quest template contains only approved integer ranges.")
	quit()
