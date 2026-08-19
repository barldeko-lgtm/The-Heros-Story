class_name HeroNameRepository
extends RefCounted

const NAMES_PATH: String = "res://data/hero_names_ru.txt"
const FALLBACK_SEED: int = 1

var random_number_generator: RandomNumberGenerator

func _init(initial_random_number_generator: RandomNumberGenerator = null) -> void:
	random_number_generator = initial_random_number_generator
	if random_number_generator == null:
		random_number_generator = RandomNumberGenerator.new()
		random_number_generator.seed = FALLBACK_SEED

func load_names() -> Array[String]:
	var names: Array[String] = []
	var file_content: String = FileAccess.get_file_as_string(NAMES_PATH)

	for line in file_content.split("\n"):
		var hero_name: String = line.strip_edges()
		if not hero_name.is_empty():
			names.append(hero_name)

	return names

func get_random_name() -> String:
	var names: Array[String] = load_names()
	if names.is_empty():
		return "Безымянный"
	return names[random_number_generator.randi_range(0, names.size() - 1)]
