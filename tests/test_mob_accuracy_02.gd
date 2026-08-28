extends SceneTree

const MOB_DIRECTORY := "res://data/mobs"
const EXPECTED_MOB_COUNT := 13

func _init() -> void:
	var directory := DirAccess.open(MOB_DIRECTORY)
	assert(directory != null, "Mob data directory must exist.")
	var mob_files: PackedStringArray = []
	for file_name in directory.get_files():
		if file_name.ends_with(".tres"):
			mob_files.append(file_name)
	mob_files.sort()
	assert(mob_files.size() == EXPECTED_MOB_COUNT, "The current mob roster must contain 13 definitions.")
	for file_name in mob_files:
		var mob: Resource = load("%s/%s" % [MOB_DIRECTORY, file_name])
		assert(mob != null, "Every mob definition must load: %s" % file_name)
		assert(is_equal_approx(mob.accuracy, 100.0), "Every current mob must temporarily use 100 Accuracy: %s" % mob.id)

	print("PASS: All 13 current mobs use the agreed temporary 100 Accuracy.")
	quit()
