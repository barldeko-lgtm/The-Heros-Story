extends SceneTree

func _init() -> void:
	var quest = load("res://data/quests/0001_goblin_road_problem.tres")
	assert(quest != null, "Goblin quest definition must exist.")
	assert(quest.id == "goblin_road_problem", "Quest ID must remain stable and semantic.")
	assert(quest.display_name == "Проблема у восточной дороги", "Quest display name must be Russian.")
	assert(quest.mob_definition.id == "goblin", "Quest must reference the Goblin definition.")
	assert(quest.mob_count == 5, "Quest must require five goblins.")
	assert(is_equal_approx(quest.distance_km, 2.0), "Quest distance must be two kilometres.")
	assert(quest.gold_reward == 20, "Quest turn-in reward must be twenty gold.")

	print("PASS: Goblin quest definition contains approved data.")
	quit()
