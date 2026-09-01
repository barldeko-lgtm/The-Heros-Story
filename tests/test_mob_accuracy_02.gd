extends SceneTree

const MOB_DIRECTORY := "res://data/mobs"
const EXPECTED_MOB_COUNT := 15

func _init() -> void:
	var directory := DirAccess.open(MOB_DIRECTORY)
	assert(directory != null, "Mob data directory must exist.")
	var mob_files: PackedStringArray = []
	for file_name in directory.get_files():
		if file_name.ends_with(".tres"):
			mob_files.append(file_name)
	mob_files.sort()
	assert(mob_files.size() == EXPECTED_MOB_COUNT, "The current mob roster must contain 15 definitions.")
	for file_name in mob_files:
		var mob: Resource = load("%s/%s" % [MOB_DIRECTORY, file_name])
		assert(mob != null, "Every mob definition must load: %s" % file_name)
		var expected_accuracy: float = 105.0 if mob.id == "orc_raider" else 100.0
		assert(is_equal_approx(mob.accuracy, expected_accuracy), "Mob Accuracy must match the currently approved tuning: %s" % mob.id)

	print("PASS: Current mob Accuracy values match the approved tuning, including the 105-Accuracy Orc Raider.")
	quit()
