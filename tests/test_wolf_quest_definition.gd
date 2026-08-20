extends SceneTree

func _init() -> void:
	var quest = load("res://data/quests/0002_wolf_hunt.tres")
	assert(quest != null, "Wolf quest must exist.")
	assert(quest.id == "wolf_hunt", "Wolf quest ID must remain stable.")
	assert(quest.display_name == "Охота на волков", "Wolf quest display name must be Russian.")
	assert(quest.mob_definition != null, "Wolf quest must reference a mob.")
	assert(quest.mob_definition.id == "wolf", "Wolf quest must use the Wolf definition.")
	assert(quest.mob_count_min == 6 and quest.mob_count_max == 8, "Wolf offer count must roll from 6 through 8.")
	assert(quest.distance_km_min == 3 and quest.distance_km_max == 5, "Wolf offer distance must roll from 3 through 5 km.")
	assert(quest.gold_per_mob_min == 12 and quest.gold_per_mob_max == 14, "Wolf offer reward must roll from 12 through 14 gold per mob.")

	print("PASS: Wolf quest template contains only approved integer ranges.")
	quit()
