extends SceneTree

func _init() -> void:
	var quest = load("res://data/quests/0002_wolf_hunt.tres")
	assert(quest != null, "Wolf quest must exist.")
	assert(quest.id == "wolf_hunt", "Wolf quest ID must remain stable.")
	assert(quest.display_name == "Охота на волков", "Wolf quest display name must be Russian.")
	assert(quest.mob_definition != null, "Wolf quest must reference a mob.")
	assert(quest.mob_definition.id == "wolf", "Wolf quest must use the Wolf definition.")
	assert(quest.mob_count == 8, "Wolf quest must contain 8 wolves.")
	assert(is_equal_approx(quest.distance_km, 4.0), "Wolf quest distance must be 4 km.")
	assert(quest.gold_reward == 80, "Wolf quest reward must be 80 gold.")

	print("PASS: Wolf quest contains 8 wolves at distance 4 with 80 gold reward.")
	quit()
